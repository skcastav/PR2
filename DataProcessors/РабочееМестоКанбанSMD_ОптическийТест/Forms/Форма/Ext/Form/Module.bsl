﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
Объект.Исполнитель = ПараметрыСеанса.Пользователь;
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
		Если Не МожноРаботатьВАРМ() Тогда
		Возврат;
		КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры

&НаСервере
Процедура ПолучитьДанныеПоЗаданиямНаСервере()
ТаблицаЗаданий.Очистить();
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.Изделие,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаНачала,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.Период,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.Количество
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПоследних КАК ЭтапыПроизводственныхЗаданийСрезПоследних
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.РабочееМесто = &РабочееМесто
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ.ДокументОснование.Статус = 4
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ.Остановлено = ЛОЖЬ
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ.ЛинияSMD = &ЛинияSMD
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаНачала = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.Ремонт = ЛОЖЬ";
Запрос.УстановитьПараметр("РабочееМесто",Объект.РабочееМесто);
Запрос.УстановитьПараметр("ЛинияSMD",Объект.Линия);
Результат = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = Результат.Выбрать();
ЕстьПриоритет = Ложь;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл 
    ТЧ = ТаблицаЗаданий.Добавить();
	ТЧ.Спецификация = ВыборкаДетальныеЗаписи.Изделие;
	ТЧ.Статус = ПолучитьСтатус(ВыборкаДетальныеЗаписи.Изделие);
	ТЧ.ПЗ = ВыборкаДетальныеЗаписи.ПЗ;
	ТЧ.Количество = ВыборкаДетальныеЗаписи.Количество;
	ТЧ.ДатаПередачи = ВыборкаДетальныеЗаписи.Период; 
	ТЧ.Приоритет = ?(ВыборкаДетальныеЗаписи.ПЗ.НомерОчереди > 0,Истина,Ложь);
	ТЧ.НомерОчереди = ВыборкаДетальныеЗаписи.ПЗ.НомерОчереди;
		Если ТЧ.Приоритет Тогда	
		ЕстьПриоритет = Истина;
		КонецЕсли; 
	КонецЦикла;
		Если ТаблицаЗаданий.Количество() > 0 Тогда
		ТаблицаЗаданий.Сортировать("Приоритет Убыв,НомерОчереди,ДатаПередачи");
			Если ЕстьПриоритет Тогда
			ТаблицаЗаданий[0].ВыборРазрешен = Истина;
			Иначе	
				Для каждого ТЧ Из ТаблицаЗаданий Цикл	
				ТЧ.ВыборРазрешен = Истина;
				КонецЦикла; 
			КонецЕсли; 
		КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьДанныеПоЗаданиям() Экспорт
ПолучитьДанныеПоЗаданиямНаСервере();
	Если Не Объект.ПроизводственноеЗадание.Пустая() Тогда
	КоличествоИзделия = ОбщийМодульВызовСервера.ПолучитьКоличествоИзделияНаРабочемМесте(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПЗОстановлено()
Возврат(Объект.ПроизводственноеЗадание.Остановлено);
КонецФункции

&НаКлиенте
Процедура ПолучитьЗадания(Команда)
ПолучитьДанныеПоЗаданиямНаСервере();
	Если Не Объект.ПроизводственноеЗадание.Пустая() Тогда
		Если ПЗОстановлено() Тогда
		ОчиститьСсылкуНаПЗ();
		ПолучитьНезавершёноеЗадание();
		КонецЕсли;
	Иначе 
	ПолучитьНезавершёноеЗадание();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьЗаданиеНаСервере(Стр)
ТЧ = ТаблицаЗаданий.НайтиПоИдентификатору(Стр);
ПЗ = ТЧ.ПЗ;
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	Парам = Новый Структура("РабочееМесто,ДатаНачала",Объект.РабочееМесто,ТекущаяДата());
	ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(ПЗ,Парам);
	Объект.ПроизводственноеЗадание = ПЗ;
	КоличествоИзделия = ТЧ.Количество;
	КоличествоВыполнено = ПолучитьВыполненноеКоличество();
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь);
	КонецПопытки;
Возврат(Истина);
КонецФункции

&НаКлиенте
Процедура ВыбратьПЗ(Команда)
	Если Объект.ПроизводственноеЗадание.Пустая() Тогда
		Если Элементы.ТаблицаЗаданий.ТекущиеДанные.ВыборРазрешен Тогда
		ПолучитьЗаданиеНаСервере(Элементы.ТаблицаЗаданий.ТекущаяСтрока);
		Элементы.ЗавершитьИПередатьНаПромывку.КнопкаПоУмолчанию = Истина;		
		ПолучитьДанныеПоЗаданиямНаСервере();
		Иначе	
		Сообщить("Выберите первое производственное задание!");
		КонецЕсли; 			
	Иначе
	Сообщить("Сначала завершите текущее производственное задание!");
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗаданийВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
ВыбратьПЗ(Неопределено);
КонецПроцедуры

&НаСервере
Процедура ОчиститьСсылкуНаПЗ()
Объект.ПроизводственноеЗадание = Документы.ПроизводственноеЗадание.ПустаяСсылка();
КоличествоИзделия = 0;
КоличествоВыполнено = 0;
КоличествоБрак = 0;
Элементы.ЗавершитьИПередатьНаПромывку.КнопкаПоУмолчанию = Ложь;
КонецПроцедуры 

&НаКлиенте
Процедура ПечатьТекущейСпецификации(Команда)
ОткрытьФорму("Отчет.ПечатьСпецификацииСУчётомАналогов.Форма.ФормаОтчета",Новый Структура("ПЗ",Объект.ПроизводственноеЗадание));
КонецПроцедуры

&НаСервере
Функция ПолучитьВыполненноеКоличество()	
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВыполнениеЭтаповПроизводства.МТК КАК МТК,
	|	ВыполнениеЭтаповПроизводства.Количество КАК Количество
	|ИЗ
	|	РегистрСведений.ВыполнениеЭтаповПроизводства КАК ВыполнениеЭтаповПроизводства
	|ГДЕ
	|	ВыполнениеЭтаповПроизводства.МТК = &МТК
	|	И ВыполнениеЭтаповПроизводства.РабочееМесто = &РабочееМесто
	|	И ВыполнениеЭтаповПроизводства.Спецификация = &Спецификация
	|ИТОГИ
	|	СУММА(Количество)
	|ПО
	|	МТК";
Запрос.УстановитьПараметр("МТК", Объект.ПроизводственноеЗадание.ДокументОснование);
Запрос.УстановитьПараметр("РабочееМесто", Объект.РабочееМесто);
Запрос.УстановитьПараметр("Спецификация", Объект.ПроизводственноеЗадание.Изделие);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаВЭП = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаВЭП.Следующий() Цикл
	Возврат(ВыборкаВЭП.Количество);
	КонецЦикла;
Возврат(0);
КонецФункции

&НаСервере
Функция ПолучитьНезавершёноеЗадание()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданий.ПЗ,
	|	ЭтапыПроизводственныхЗаданий.Количество
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий КАК ЭтапыПроизводственныхЗаданий
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданий.РабочееМесто = &РабочееМесто
	|	И ЭтапыПроизводственныхЗаданий.ПЗ.ДокументОснование.Статус = 4
	|	И ЭтапыПроизводственныхЗаданий.ПЗ.Остановлено = ЛОЖЬ
	|	И ЭтапыПроизводственныхЗаданий.ДатаНачала <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ЭтапыПроизводственныхЗаданий.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ЭтапыПроизводственныхЗаданий.ПЗ.ЛинияSMD = &ЛинияSMD
	|	И ЭтапыПроизводственныхЗаданий.Ремонт = ЛОЖЬ";
Запрос.УстановитьПараметр("РабочееМесто",Объект.РабочееМесто);
Запрос.УстановитьПараметр("ЛинияSMD",Объект.Линия);
Результат = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = Результат.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
    Объект.ПроизводственноеЗадание = ВыборкаДетальныеЗаписи.ПЗ;
	КоличествоИзделия = ВыборкаДетальныеЗаписи.Количество;
	КоличествоВыполнено = ПолучитьВыполненноеКоличество();
	КоличествоБрак = ОбщийМодульВызовСервера.ПолучитьКоличествоВБракеПоПЗ(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);
	Возврат(Истина); 
	КонецЦикла;
Возврат(Ложь);
КонецФункции

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

&НаКлиенте
Процедура РабочееМестоПриИзменении(Элемент)
	Если Не МожноРаботатьВАРМ() Тогда
	Возврат;
	КонецЕсли;
ОчиститьСсылкуНаПЗ();
Объект.Линия = "";
ОтключитьОбработчикОжидания("ПолучитьДанныеПоЗаданиям");
КонецПроцедуры

&НаСервере
Функция ПолучитьКодРабочегоМеста(РабочееМесто)
Возврат(РабочееМесто.Код);
КонецФункции

&НаКлиенте
Процедура РабочееМестоОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Если ПолучитьКодРабочегоМеста(ВыбранноеЗначение) <> 2 Тогда
	СтандартнаяОбработка = Ложь;
	Сообщить("Выберите рабочее место Оптический тест!");	
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция УстановкаЭлементовЗавершена()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.ДатаОкончания
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПервых КАК ЭтапыПроизводственныхЗаданийСрезПервых
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.ПЗ = &ПЗ";
Запрос.УстановитьПараметр("ПЗ",Объект.ПроизводственноеЗадание);
Результат = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = Результат.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Возврат(ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания)); 
	КонецЦикла;
КонецФункции

&НаСервере
Функция ЗавершитьЭтапНаСервере()
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	Парам = Новый Структура("РабочееМесто,Исполнитель,ДатаОкончания",Объект.РабочееМесто,Объект.Исполнитель,ТекущаяДата());
	ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(Объект.ПроизводственноеЗадание,Парам);
	Парам = Новый Структура("РабочееМесто,Количество",ОбщийМодульВызовСервера.ПолучитьСледующееРабочееМесто(Объект.РабочееМесто),КоличествоИзделия-КоличествоБрак);
	ОбщийМодульРаботаСРегистрами.СоздатьЭтапПроизводственногоЗаданияКанбан(Объект.ПроизводственноеЗадание,Парам);
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Возврат(Истина);
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	КонецПопытки;
Возврат(Ложь);
КонецФункции

&НаКлиенте
Процедура Завершить(Команда)
Результат = ОткрытьФормуМодально("Обработка.РабочееМестоКанбанSMD_ОптическийТест.Форма.ФормаЗавершениеЭтапов",Новый Структура("ПроизводственноеЗадание,РабочееМесто,Исполнитель",Объект.ПроизводственноеЗадание,Объект.РабочееМесто,Объект.Исполнитель));
	Если Результат <> Неопределено Тогда
		Если Результат Тогда
			Если Не Объект.ПроизводственноеЗадание.Пустая() Тогда
				Если УстановкаЭлементовЗавершена() Тогда
				КоличествоИзделия = ОбщийМодульВызовСервера.ПолучитьКоличествоИзделияНаРабочемМесте(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);
					Если ЗавершитьЭтапНаСервере() Тогда
					ОчиститьСсылкуНаПЗ();
					ПолучитьНезавершёноеЗадание();
					КонецЕсли;		
				Иначе	
				Сообщить("Установка элементов не завершена!");
				КонецЕсли;		  
			Иначе
			Сообщить("Выберите производственное задание!");
			КонецЕсли;
		Иначе
		ОчиститьСсылкуНаПЗ();
		ПолучитьНезавершёноеЗадание();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЛинияПриИзменении(Элемент)
ОчиститьСсылкуНаПЗ();
	Если ПолучитьНезавершёноеЗадание() Тогда
	Элементы.ЗавершитьИПередатьНаПромывку.КнопкаПоУмолчанию = Истина;
	КонецЕсли;
ПолучитьДанныеПоЗаданиямНаСервере();
	Если Объект.ИнтервалОбновления > 0 Тогда
	ПодключитьОбработчикОжидания("ПолучитьДанныеПоЗаданиям", Объект.ИнтервалОбновления*60);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОбновленияПриИзменении(Элемент)
ОтключитьОбработчикОжидания("ПолучитьДанныеПоЗаданиям");
	Если Объект.ИнтервалОбновления > 0 Тогда
	ПодключитьОбработчикОжидания("ПолучитьДанныеПоЗаданиям", Объект.ИнтервалОбновления*60);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОформитьБрак(Команда)
	Если Объект.ПроизводственноеЗадание.Пустая() Тогда
	Сообщить("Нет выбранного производственного задания!");
	Возврат;	
	КонецЕсли;
КоличествоИзделия = ОбщийМодульВызовСервера.ПолучитьКоличествоИзделияНаРабочемМесте(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);
Результат = ОткрытьФормуМодально("ОбщаяФорма.ОформлениеБракаКанбан",Новый Структура("РабочееМесто,ПЗ,КоличествоИзделия",Объект.РабочееМесто,Объект.ПроизводственноеЗадание,КоличествоИзделия - КоличествоБрак));
	Если Результат <> 0 Тогда
	КоличествоБрак = ОбщийМодульВызовСервера.ПолучитьКоличествоВБракеПоПЗ(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Ремонт(Команда)
	Если Объект.ПроизводственноеЗадание.Пустая() Тогда
	Сообщить("Нет выбранного производственного задания!");
	Возврат;	
	КонецЕсли;
КоличествоИзделия = ОбщийМодульВызовСервера.ПолучитьКоличествоИзделияНаРабочемМесте(Объект.ПроизводственноеЗадание,Объект.РабочееМесто);
Результат = ОткрытьФормуМодально("ОбщаяФорма.ОформлениеРемонтКанбан",Новый Структура("РабочееМесто,ПЗ,КоличествоИзделия",Объект.РабочееМесто,Объект.ПроизводственноеЗадание,КоличествоИзделия - КоличествоБрак));
	Если Результат <> 0 Тогда
	ОчиститьСсылкуНаПЗ();		
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьИзделие()
Возврат(Объект.ПроизводственноеЗадание.Изделие);
КонецФункции

&НаКлиенте
Процедура ОтчётПоИзменениям(Команда)
ОткрытьФорму("Отчет.ОтчётПоИзменениямВСпецификации.Форма.ФормаОтчета",Новый Структура("Спецификация",ПолучитьИзделие()));
КонецПроцедуры
