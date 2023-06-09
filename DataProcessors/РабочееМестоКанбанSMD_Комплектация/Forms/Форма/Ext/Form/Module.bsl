﻿
&НаСервере 
Перем ТаблицаСклада,ТаблицаСкладаКопия;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
Объект.Исполнитель = ПараметрыСеанса.Пользователь;
МестоХраненияОткуда = 2; 
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
ОписаниеОшибки = "";
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
	Если Не МенеджерОборудованияКлиент.ПодключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО, ОписаниеОшибки) Тогда
	ТекстСообщения = НСтр("ru = 'При подключении оборудования произошла ошибка:""%ОписаниеОшибки%"".'");
	ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ОписаниеОшибки%" , ОписаниеОшибки);
	Сообщить(ТекстСообщения);
	КонецЕсли;
		Если Не Объект.РабочееМесто.Пустая() Тогда
		РабочееМестоПриИзменении(Неопределено);
		КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры

&НаСервере
Функция НайтиМПЗ(НаименованиеSMD,Количество)
Иден = Неопределено;
	Для каждого ТЧ Из ТаблицаПеремещений Цикл
		Если Количество > 0 Тогда
			Если СокрЛП(ТЧ.МПЗ.НаименованиеSMD) = НаименованиеSMD Тогда
			Иден = ТЧ.ПолучитьИдентификатор();
				Если ТЧ.МестоХранения = СписокМестХранения[МестоХраненияОткуда].Значение Тогда
				ТЧ.КоличествоПереместить = ТЧ.КоличествоПереместить + Количество;
				КонецЕсли;			
			КонецЕсли;	
		КонецЕсли;
	КонецЦикла;
Возврат(Иден); 
КонецФункции

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	Если ЭтаФорма.ВводДоступен() Тогда
		Если Найти(Данные,"*") > 0 Тогда
		Массив = ОбщийМодульВызовСервера.РазложитьСтрокуВМассив(Данные,"$");
		Результат = НайтиМПЗ(Сред(Массив[0],2),Число(СтрЗаменить(Массив[2],"*","")));	
			Если Результат <> Неопределено Тогда	
			Элементы.ТаблицаПеремещений.ТекущаяСтрока = Результат;
			Иначе
			Предупреждение("МПЗ не найден!");
			КонецЕсли; 
		Иначе
		Сообщить("Неверный QRCode!");
		КонецЕсли;
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция МожноРаботатьВАРМ()
	Если ОбщийМодульВызовСервера.МожноВыполнить(Объект.РабочееМесто.Линейка) Тогда	
	Возврат(Истина);
	Иначе
	Объект.РабочееМесто = Справочники.РабочиеМестаЛинеек.ПустаяСсылка();
	Сообщить("Работа АРМ запрещена в этой базе!");
	Возврат(Ложь);
	КонецЕсли;
КонецФункции

&НаСервере
Процедура ДобавитьМестаХранения()
СписокМестХранения.Очистить();
СписокМестХранения.Добавить(Объект.РабочееМесто.Линейка.МестоХраненияКанбанов);
СписокМестХранения.Добавить(Объект.РабочееМесто.Линейка.Подразделение.МестоХраненияДополнительный);
СписокМестХранения.Добавить(Объект.РабочееМесто.Линейка.Подразделение.МестоХраненияПоУмолчанию);
КонецПроцедуры 

&НаКлиенте
Процедура РабочееМестоПриИзменении(Элемент)
	Если Не МожноРаботатьВАРМ() Тогда
	Возврат;
	КонецЕсли;
ДобавитьМестаХранения();
ПолучитьЗаданияНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПолучитьЗаданияНаСервере()
ТаблицаЗаданий.Очистить();
ТаблицаПеремещений.Очистить();
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ КАК ПЗ
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПоследних КАК ЭтапыПроизводственныхЗаданийСрезПоследних
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.РабочееМесто = &РабочееМесто
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ.ДокументОснование.Статус = 4
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаНачала";
Запрос.УстановитьПараметр("РабочееМесто",Объект.РабочееМесто);
Результат = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = Результат.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл	  
    ТЧ = ТаблицаЗаданий.Добавить();
	ТЧ.Статус = ПолучитьСтатус(ВыборкаДетальныеЗаписи.ПЗ.Изделие);
	ТЧ.ПЗ = ВыборкаДетальныеЗаписи.ПЗ;
	ТЧ.СтатусМТК = ВыборкаДетальныеЗаписи.ПЗ.ДокументОснование.Статус;
	ТЧ.МестоХраненияПотребитель = ВыборкаДетальныеЗаписи.ПЗ.ДокументОснование.МестоХраненияПотребитель;
	КонецЦикла;
Элементы.СоздатьСписокПеремещений.Доступность = ?(ТаблицаЗаданий.Количество() > 0,Истина,Ложь);
Элементы.СоздатьПеремещения.Доступность = Ложь;
Элементы.СоздатьПередачиВПроизводство.Доступность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьЗадания(Команда)
ПолучитьЗаданияНаСервере();
КонецПроцедуры

&НаСервере
Процедура ДобавитьВТаблицуПеремещений(МПЗ,Количество,МестоХранения)
Выборка = ТаблицаПеремещений.НайтиСтроки(Новый Структура("МестоХранения,МПЗ",МестоХранения,МПЗ));					
	Если Выборка.Количество() = 0 Тогда
	ТЧ_П = ТаблицаПеремещений.Добавить();
	ТЧ_П.МестоХранения = МестоХранения;
	ТЧ_П.ГруппаМПЗ = ПолучитьВерхнегоРодителя(МПЗ);
	ТЧ_П.МПЗ = МПЗ;
	ТЧ_П.Количество =  Количество;
	Иначе
	Выборка[0].Количество = Выборка[0].Количество + Количество;	
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура РаскрытьНаМПЗиПроверить(ЭтапСпецификации,КолУзла)
ВыборкаНР = ОбщийМодульВызовСервера.ПолучитьНормыРасходовПоВладельцу_Н_М(ЭтапСпецификации,ТекущаяДата());
	Пока ВыборкаНР.Следующий() Цикл
		Если ТипЗнч(ВыборкаНР.Элемент) = Тип("СправочникСсылка.Номенклатура")Тогда
			Если ВыборкаНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Набор Тогда
			РаскрытьНаМПЗиПроверить(ВыборкаНР.Элемент,ПолучитьБазовоеКоличество(ВыборкаНР.Норма,ВыборкаНР.Элемент.ОсновнаяЕдиницаИзмерения)*КолУзла);
			Продолжить;
			ИначеЕсли Не ВыборкаНР.Элемент.Канбан.Пустая() Тогда
				Если Не ВыборкаНР.Элемент.Канбан.РезервироватьВПроизводстве Тогда		
				Продолжить;
				КонецЕсли;			
			КонецЕсли;
		Выборка = Этапы.НайтиСтроки(Новый Структура("ЭтапСпецификации",ВыборкаНР.Элемент));
        	Если Выборка.Количество() > 0 Тогда
			Продолжить;
			КонецЕсли;
		КонецЕсли;
	ТаблицаМПЗ.Очистить();
	ТЧ = ТаблицаМПЗ.Добавить();
	ТЧ.МПЗ = ВыборкаНР.Элемент;
	ТЧ.Количество = ПолучитьБазовоеКоличество(ВыборкаНР.Норма,ВыборкаНР.Элемент.ОсновнаяЕдиницаИзмерения)*КолУзла;
	ТЧ.Приоритет = 1;
	ТаблицаАналогов = ОбщегоНазначенияПовтИсп.ПолучитьАналогиНормРасходов(ВыборкаНР.Ссылка,ТекущаяДата(),Истина);
		Для каждого ТЧ_ТА Из ТаблицаАналогов Цикл
		ТЧ = ТаблицаМПЗ.Добавить();
		ТЧ.МПЗ = ТЧ_ТА.Элемент;
		ТЧ.Количество = ПолучитьБазовоеКоличество(ТЧ_ТА.Норма,ТЧ_ТА.Элемент.ОсновнаяЕдиницаИзмерения)*КолУзла; 
		ТЧ.Приоритет = ?(ПолучитьСтатус(ТЧ_ТА.Элемент) = Перечисления.СтатусыМПЗ.ДоИсчерпанияЗапасов,0,ТЧ_ТА.Ссылка.Приоритет + 1);
		КонецЦикла;
	ТаблицаМПЗ.Сортировать("Приоритет");
		Для каждого ТЧ Из ТаблицаМПЗ Цикл
		КоличествоТребуется = ТЧ.Количество;
		Количество1 = 0;
		Количество2 = 0;
		Выборка = ТаблицаСклада.НайтиСтроки(Новый Структура("МестоХранения,МПЗ",СписокМестХранения[0].Значение,ТЧ.МПЗ));
			Если Выборка.Количество() > 0 Тогда
				Если Выборка[0].Количество > 0 Тогда
					Если Выборка[0].Количество >= КоличествоТребуется Тогда
					Выборка[0].Количество = Выборка[0].Количество - КоличествоТребуется;
					КоличествоТребуется = 0;
					Иначе
					КоличествоТребуется = КоличествоТребуется - Выборка[0].Количество;
					Выборка[0].Количество = 0;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
				Если КоличествоТребуется > 0 Тогда
				Выборка1 = ТаблицаСклада.НайтиСтроки(Новый Структура("МестоХранения,МПЗ",СписокМестХранения[1].Значение,ТЧ.МПЗ));
					Если Выборка1.Количество() > 0 Тогда
						Если Выборка1[0].Количество > 0 Тогда
							Если Выборка1[0].Количество >= КоличествоТребуется Тогда
							Количество1 = КоличествоТребуется;
							КоличествоТребуется = 0;
							Иначе
							Количество1 = Выборка1[0].Количество;
							КоличествоТребуется = КоличествоТребуется - Выборка1[0].Количество;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
					Если КоличествоТребуется > 0 Тогда
					Выборка2 = ТаблицаСклада.НайтиСтроки(Новый Структура("МестоХранения,МПЗ",СписокМестХранения[2].Значение,ТЧ.МПЗ));
						Если Выборка2.Количество() > 0 Тогда
							Если Выборка2[0].Количество > 0 Тогда
								Если Выборка2[0].Количество >= КоличествоТребуется Тогда
								Количество2 = КоличествоТребуется;
								КоличествоТребуется = 0;
								Иначе
								Количество2 = Выборка2[0].Количество;
								КоличествоТребуется = КоличествоТребуется - Выборка2[0].Количество;
								КонецЕсли;
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
						Если КоличествоТребуется = 0 Тогда
							Если Количество1 > 0 Тогда
							Выборка1[0].Количество = Выборка1[0].Количество - Количество1;
							ДобавитьВТаблицуПеремещений(ТЧ.МПЗ,Количество1,СписокМестХранения[1].Значение);						
							КонецЕсли; 
								Если Количество2 > 0 Тогда
								Выборка2[0].Количество = Выборка2[0].Количество - Количество2;
								ДобавитьВТаблицуПеремещений(ТЧ.МПЗ,Количество2,СписокМестХранения[2].Значение);						
								КонецЕсли;
						Прервать;
						КонецЕсли; 
		КонецЦикла;	
        	Если КоличествоТребуется > 0 Тогда
			СписокЛО.Добавить(ВыборкаНР.Ссылка);
			КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуМПЗИПроверить(ПЗ)
Этапы.Очистить();
ЭтапыАРМ.Очистить();
СписокЛО.Очистить();
РезультатПроверки = ОбщийМодульСозданиеДокументов.ПроверитьЭтапыСпецификации(Объект.РабочееМесто.Линейка,ПЗ.Изделие);
	Если Не РезультатПроверки.Пустая() Тогда
	Сообщить("Не найдено рабочее место для "+РезультатПроверки);
	Возврат(Истина);
	КонецЕсли;
ОбщийМодульВызовСервера.ПолучитьТаблицуЭтаповСпецификации(Этапы,ПЗ.Изделие,ПЗ.Количество,Ложь,ТекущаяДата());
СохранитьТаблицуСклада();
	Для каждого ТЧ Из Этапы Цикл
	РаскрытьНаМПЗиПроверить(ТЧ.ЭтапСпецификации,ТЧ.Количество);
	КонецЦикла;
		Если СписокЛО.Количество() = 0 Тогда
		Возврат(Истина);
		Иначе
		ОбщийМодульРаботаСРегистрами.ОбработкаЛьготнойОчереди(ПЗ,СписокЛО);
		ВосстановитьТаблицуСклада();
		Возврат(Ложь);
		КонецЕсли; 
КонецФункции 

&НаСервере
Процедура ПолучитьТаблицуСклада()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОстатки.МестоХранения КАК МестоХранения,
	|	МестаХраненияОстатки.МПЗ КАК МПЗ,
	|	МестаХраненияОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.МестаХранения.Остатки(&НаДату, МестоХранения В (&СписокМестХранения)) КАК МестаХраненияОстатки";
Запрос.УстановитьПараметр("СписокМестХранения", СписокМестХранения);
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
ТаблицаСклада = Запрос.Выполнить().Выгрузить();
ТаблицаСклада.Индексы.Добавить("МестоХранения");
ТаблицаСклада.Индексы.Добавить("МПЗ");
КонецПроцедуры

&НаСервере
Процедура СохранитьТаблицуСклада()
ТаблицаСкладаКопия = ТаблицаСклада.Скопировать(); 
КонецПроцедуры 

&НаСервере
Процедура ВосстановитьТаблицуСклада()
ТаблицаСклада = ТаблицаСкладаКопия.Скопировать(); 
КонецПроцедуры 

&НаСервере
Процедура НайтиПлату(ПЗ,ЭтапСпецификации,Плата)
ВыборкаНР = ОбщийМодульВызовСервера.ПолучитьНормыРасходовПоВладельцу_Н_М(ЭтапСпецификации,ТекущаяДата());
	Пока ВыборкаНР.Следующий() Цикл
		Если ТипЗнч(ВыборкаНР.Элемент) = Тип("СправочникСсылка.Номенклатура")Тогда
		НайтиПлату(ПЗ,ВыборкаНР.Элемент,Плата);
			Если Плата <> Неопределено Тогда
			Возврат;
			КонецЕсли;
		Иначе
			Если Найти(ПолучитьВерхнегоРодителя(ВыборкаНР.Элемент).Наименование,"0 - Платы") > 0 Тогда
			Плата = ВыборкаНР.Элемент;
			Возврат;			
			КонецЕсли; 
		КонецЕсли; 	
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция ОтчётПоПеремещениюНаСервере()
ТабДок = Новый ТабличныйДокумент;

ОбъектЗн = РеквизитФормыВЗначение("Объект");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблМестоХранения = Макет.ПолучитьОбласть("МестоХранения");
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");
ОблКонец = Макет.ПолучитьОбласть("Конец");
ОблШапка2 = Макет.ПолучитьОбласть("Шапка2");
ОблПЗ = Макет.ПолучитьОбласть("ПЗ");
ОблКонец2 = Макет.ПолучитьОбласть("Конец2");

ОблШапка.Параметры.Линейка = СокрЛП(Объект.РабочееМесто.Линейка.Наименование);
ОблШапка.Параметры.НаДату = ТекущаяДата();
ОблШапка.Параметры.Исполнитель = ПараметрыСеанса.Пользователь;
КоличествоМТК = 0;  		
	Для каждого ТЧ Из ТаблицаЗаданий Цикл
		Если ТЧ.Пометка Тогда
		КоличествоМТК = КоличествоМТК + 1;
		КонецЕсли; 	
	КонецЦикла;	
ОблШапка.Параметры.КоличествоМТК = КоличествоМТК;
ОблШапка.Параметры.КоличествоПозиций = ТаблицаПеремещений.Количество();
ТабДок.Вывести(ОблШапка);
МестоХранения = Неопределено;
	Для каждого ТЧ Из ТаблицаПеремещений Цикл
		Если Найти(ТЧ.ГруппаМПЗ.Наименование,"0 - Платы") > 0 Тогда
		Продолжить;
		КонецЕсли; 
			Если ТЧ.МестоХранения <> МестоХранения Тогда
			ОблМестоХранения.Параметры.МестоХранения = ТЧ.МестоХранения;
			ТабДок.Вывести(ОблМестоХранения);
			МестоХранения = ТЧ.МестоХранения;
			КонецЕсли;	
	ОблМПЗ.Параметры.Наименование = ТЧ.МПЗ.Наименование;
	ОблМПЗ.Параметры.ГруппаМПЗ = СокрЛП(ТЧ.ГруппаМПЗ.Наименование);
	ОблМПЗ.Параметры.МПЗ = ТЧ.МПЗ;
	ОблМПЗ.Параметры.Количество = ТЧ.Количество;
	ОблМПЗ.Параметры.КоличествоОстаток = ОбщийМодульВызовСервера.ПолучитьОстатокПоМестуХранения(ТЧ.МестоХранения,ТЧ.МПЗ);
	ОблМПЗ.Параметры.ЕдиницаИзмерения = СокрЛП(ТЧ.МПЗ.ЕдиницаИзмерения.Наименование);
		Если ТЧ.МПЗ.СтационарныеПитатели.Найти(Объект.РабочееМесто.Линейка,"Линейка") <> Неопределено Тогда
		ОблМПЗ.Параметры.СтационарныйПитатель = "+";
		Иначе
		ОблМПЗ.Параметры.СтационарныйПитатель = "";
		КонецЕсли; 
	ЯХ = ОбщийМодульРаботаСРегистрами.ПолучитьЯчейкуХранения(ТЧ.МПЗ,ТЧ.МестоХранения);
		Если ЯХ <> Неопределено Тогда
		ОблМПЗ.Параметры.Стеллаж = ЯХ.Стеллаж;
		ОблМПЗ.Параметры.Стойка = ЯХ.Стойка;
		ОблМПЗ.Параметры.Полка = ЯХ.Полка;
		ОблМПЗ.Параметры.Ячейка = ЯХ.Ячейка;
		Иначе
		ОблМПЗ.Параметры.Стеллаж = "";
		ОблМПЗ.Параметры.Стойка = "";
		ОблМПЗ.Параметры.Полка = "";
		ОблМПЗ.Параметры.Ячейка = "";
		КонецЕсли;		
	ТабДок.Вывести(ОблМПЗ);	
	КонецЦикла;	
ТабДок.Вывести(ОблКонец);

ОблШапка2.Параметры.Линейка = Объект.РабочееМесто.Линейка;
ТабДок.Вывести(ОблШапка2);
	Для каждого ТЧ Из ТаблицаЗаданий Цикл	
		Если ТЧ.Пометка Тогда
		ОблПЗ.Параметры.Потребитель = ТЧ.МестоХраненияПотребитель;
		ОблПЗ.Параметры.НомерЯчейки = ТЧ.ПЗ.ДокументОснование.НомерЯчейки;
		ОблПЗ.Параметры.Изделие = СокрЛП(ТЧ.ПЗ.Изделие);
		ОблПЗ.Параметры.Количество = ТЧ.ПЗ.Количество;
		Плата = Неопределено;
		НайтиПлату(ТЧ.ПЗ,ТЧ.ПЗ.Изделие,Плата);
			Если Плата <> Неопределено Тогда
			ОблПЗ.Параметры.КоличествоМ = ?(Плата.КратностьЗаготовки > 0,ТЧ.ПЗ.Количество/Плата.КратностьЗаготовки,0);
			ЯХ = ОбщийМодульРаботаСРегистрами.ПолучитьЯчейкуХранения(Плата,Объект.РабочееМесто.Линейка.Подразделение.МестоХраненияПоУмолчанию);
				Если ЯХ <> Неопределено Тогда
				ОблПЗ.Параметры.Стеллаж = ЯХ.Стеллаж;
				ОблПЗ.Параметры.Стойка = ЯХ.Стойка;
				ОблПЗ.Параметры.Полка = ЯХ.Полка;
				ОблПЗ.Параметры.Ячейка = ЯХ.Ячейка;
				Иначе
				ОблПЗ.Параметры.Стеллаж = "";
				ОблПЗ.Параметры.Стойка = "";
				ОблПЗ.Параметры.Полка = "";
				ОблПЗ.Параметры.Ячейка = "";
				КонецЕсли;
			Иначе
			ОблПЗ.Параметры.КоличествоМ = 0;
			ОблПЗ.Параметры.Стеллаж = "";
			ОблПЗ.Параметры.Стойка = "";
			ОблПЗ.Параметры.Полка = "";
			ОблПЗ.Параметры.Ячейка = "";
			КонецЕсли;
		ТабДок.Вывести(ОблПЗ);
		КонецЕсли;	
	КонецЦикла; 
ТабДок.Вывести(ОблКонец2);
ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
ТабДок.ПолеСверху = 0;
ТабДок.ПолеСлева = 0;
ТабДок.ПолеСнизу = 0;
ТабДок.ПолеСправа = 0;
ТабДок.АвтоМасштаб = Истина;
Возврат(ТабДок);
КонецФункции 
   
&НаСервере
Функция СоздатьСписокПеремещенийНаСервере()
ТаблицаПеремещений.Очистить();
ПолучитьТаблицуСклада();
	Если ТаблицаСклада.Количество() > 0 Тогда
		Для каждого ТЧ Из ТаблицаЗаданий Цикл
			Если ТЧ.Пометка Тогда
			ТЧ.ЛОSMD = Не ПолучитьТаблицуМПЗИПроверить(ТЧ.ПЗ);
			КонецЕсли; 	
		КонецЦикла;
	Возврат(Истина); 
	Иначе
	Сообщить("Таблица остатков по местам хранения пустая!");
	КонецЕсли;                                              
Возврат(Ложь);
КонецФункции 

&НаКлиенте
Процедура СоздатьСписокПеремещений(Команда)
Состояние("Обработка...",,"Создание списка перемещений");
	Если СоздатьСписокПеремещенийНаСервере() Тогда
		Если ТаблицаПеремещений.Количество() > 0 Тогда
		ТаблицаПеремещений.Сортировать("МестоХранения,ГруппаМПЗ,МПЗ");
		ТД = ОтчётПоПеремещениюНаСервере();
		ТД.Показать("Список перемещений на склад канбанов");
		ТД.ФиксацияСверху = 3;
		Элементы.СоздатьСписокПеремещений.Доступность = Ложь;
		Элементы.СоздатьПеремещения.Доступность = Истина;
		Иначе
        Элементы.СоздатьСписокПеремещений.Доступность = Ложь;
        Элементы.СоздатьПередачиВПроизводство.Доступность = Истина;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция СоздатьДвижениеМПЗНаСервере(Склад)
МестоХранения = СписокМестХранения[Склад].Значение;
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	Перемещение = Документы.ДвижениеМПЗ.СоздатьДокумент();
	Перемещение.Дата = ТекущаяДата();
	Перемещение.УстановитьНовыйНомер(ПрисвоитьПрефикс(МестоХранения.Подразделение));
	Перемещение.Автор = ПараметрыСеанса.Пользователь;
	Перемещение.Подразделение = МестоХранения.Подразделение;
	Перемещение.МестоХранения = МестоХранения;
	Перемещение.МестоХраненияВ = Объект.РабочееМесто.Линейка.МестоХраненияКанбанов;  
	Перемещение.Сотрудник = Объект.Исполнитель;
	Перемещение.Комментарий = "Перемещение комплектации на линейку";
		Для каждого ТЧ Из ТаблицаПеремещений Цикл
			Если ТЧ.МестоХранения = МестоХранения Тогда
			ТЧ_П = Перемещение.ТабличнаяЧасть.Добавить();
			ТЧ_П.ВидМПЗ = Перечисления.ВидыМПЗ.Материалы;
			ТЧ_П.МПЗ = ТЧ.МПЗ;
			ТЧ_П.Количество = ТЧ.КоличествоПереместить;
			ТЧ_П.ЕдиницаИзмерения =  ТЧ.МПЗ.ОсновнаяЕдиницаИзмерения;
			КонецЕсли;
		КонецЦикла;
			Если Перемещение.ТабличнаяЧасть.Количество() > 0 Тогда
			Перемещение.Записать(РежимЗаписиДокумента.Запись);
			ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
			Возврат(Перемещение.Ссылка);
			Иначе
			ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
			Возврат(Документы.ДвижениеМПЗ.ПустаяСсылка());
			КонецЕсли; 
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Документы.ДвижениеМПЗ.ПустаяСсылка());
	КонецПопытки; 
КонецФункции

&НаСервере
Функция ПроверитьТаблицуПеремещений()
	Для каждого ТЧ Из ТаблицаПеремещений Цикл
		Если ТЧ.КоличествоПереместить < ТЧ.Количество Тогда
		Сообщить(""+ТЧ.МПЗ+" - перемещаемое кол-во меньше требуемого!");
		Возврат(Ложь);
		КонецЕсли; 
	КонецЦикла;
Возврат(Истина);
КонецФункции 

&НаКлиенте
Процедура СоздатьПеремещения(Команда)
Состояние("Обработка...",,"Создание Движений МПЗ");
	Если ТаблицаПеремещений.Количество() > 0 Тогда
		Если ПроверитьТаблицуПеремещений() Тогда
		Док = СоздатьДвижениеМПЗНаСервере(1);
			Если Не Док.Пустая() Тогда
			ОткрытьФорму("Документ.ДвижениеМПЗ.ФормаОбъекта",Новый Структура("Ключ",Док));
			КонецЕсли; 
		Док = СоздатьДвижениеМПЗНаСервере(2);
			Если Не Док.Пустая() Тогда
			ОткрытьФорму("Документ.ДвижениеМПЗ.ФормаОбъекта",Новый Структура("Ключ",Док));
			КонецЕсли;
		Элементы.СоздатьПеремещения.Доступность = Ложь;
		Элементы.СоздатьПередачиВПроизводство.Доступность = Истина;
		КонецЕсли;	
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция СоздатьПередачВПроизводствоНаСервере()
Результат = Истина;
СписокТЧ = Новый СписокЗначений;

	Для каждого ТЧ Из ТаблицаЗаданий Цикл
		Если ТЧ.Пометка Тогда
			Если ОбщийМодульВызовСервера.СоздатьТаблицуЭтаповПроизводства(ТЧ.ПЗ,Этапы,ЭтапыАРМ,Объект.РабочееМесто,Объект.Исполнитель) Тогда
				Попытка
				НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
				Результат = ОбщийМодульВызовСервера.ЗапуститьВПроизводство(ТЧ.ПЗ,Объект.РабочееМесто,Этапы,Неопределено,Ложь);
					Если Результат = 1 Тогда
					ДатаОкончания = ТекущаяДата();
					ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(ТЧ.ПЗ,Новый Структура("РабочееМесто,Исполнитель,ДатаОкончания",Объект.РабочееМесто,Объект.Исполнитель,ДатаОкончания)); 			
					ОбщийМодульРаботаСРегистрами.СоздатьЭтапПроизводственногоЗадания(ТЧ.ПЗ,ОбщийМодульВызовСервера.ПолучитьСледующееРабочееМесто(Объект.РабочееМесто),Неопределено,Неопределено);
					МТКОбъект = ТЧ.ПЗ.ДокументОснование.ПолучитьОбъект();
					МТКОбъект.Статус = 1;
					МТКОбъект.Записать(РежимЗаписиДокумента.Запись);
					ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
					СписокТЧ.Добавить(ТЧ);
					ИначеЕсли Результат = 0 Тогда
					ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(ТЧ.ПЗ,Новый Структура("РабочееМесто,ДатаНачала",Объект.РабочееМесто,Дата(1,1,1)));
					МТКОбъект = ТЧ.ПЗ.ДокументОснование.ПолучитьОбъект();
					МТКОбъект.Статус = 0;
					МТКОбъект.Записать(РежимЗаписиДокумента.Запись);
					ТЧ.Комментарий = "ЛО";
					ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
					Результат = Ложь;
					Прервать;
					ИначеЕсли Результат = -1 Тогда
					ТЧ.Комментарий = "Ошибка при создании ПП";				
					ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
					Результат = Ложь;
					Прервать;
					КонецЕсли;
				Исключение
				ТЧ.Комментарий = ОписаниеОшибки();
				ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
				Результат = Ложь;
				Прервать;
				КонецПопытки; 
			Иначе
			ТЧ.Комментарий = "Остановлено";
			Результат = Ложь;
			Прервать;	
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
		Для каждого Стр Из СписокТЧ Цикл
		ТаблицаЗаданий.Удалить(Стр.Значение);
		КонецЦикла; 		
Возврат(Результат);
КонецФункции 

&НаКлиенте
Процедура СоздатьПередачиВПроизводство(Команда)
Состояние("Обработка...",,"Создание передач в производство");
Результат = СоздатьПередачВПроизводствоНаСервере();
	Если Результат Тогда
	ТаблицаЗаданий.Очистить();
	ТаблицаПеремещений.Очистить();                           
	ОчиститьСообщения();
	Элементы.СоздатьСписокПеремещений.Доступность = Ложь;
	Элементы.СоздатьПеремещения.Доступность = Ложь;
	Элементы.СоздатьПередачиВПроизводство.Доступность = Ложь;
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПолучитьСпецификацию(ПЗ)
Возврат(ПЗ.Изделие);
КонецФункции 

&НаКлиенте
Процедура ОтчётПоИзмененияВСпецификации(Команда)
	Если Элементы.ТаблицаЗаданий.ТекущаяСтрока <> Неопределено Тогда
	ОткрытьФорму("Отчет.ОтчётПоИзменениямВСпецификации.Форма.ФормаОтчета",Новый Структура("Спецификация",ПолучитьСпецификацию(Элементы.ТаблицаЗаданий.ТекущиеДанные.ПЗ)));
	КонецЕсли; 
КонецПроцедуры
