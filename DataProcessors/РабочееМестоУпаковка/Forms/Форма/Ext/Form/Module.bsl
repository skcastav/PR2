﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
Объект.Исполнитель = ПараметрыСеанса.Пользователь;
	Если Константы.КодБазы.Получить() = "БГР" Тогда
	ИзменитьПоМаске = Истина;
	КонецЕсли;
		Если Объект.Исполнитель.Пустая() Тогда
		Элементы.РабочееМесто.Доступность = Ложь;
		Сообщить("Вы не внесены в справочник Сотрудников! Работа невозможна!");
		КонецЕсли; 
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
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДерево(ЭтапСпецификации)
Объект.Спецификация.Сортировать("ТипСправочника Убыв,ВидМПЗ,Позиция,МПЗ");
тДерево = РеквизитФормыВЗначение("ДеревоСпецификации");
тДерево.Строки.Очистить();
ТипСпр = "";
	Для каждого ТЧ Из Объект.Спецификация Цикл
		Если ТЧ.ЭтапСпецификации <> ЭтапСпецификации Тогда
		Продолжить;		
		КонецЕсли; 
			Если ТипСпр <> ТЧ.ТипСправочника Тогда
			Стр = тДерево.Строки.Добавить();
			Стр.ТипСправочника = ТЧ.ТипСправочника;
			ТипСпр = ТЧ.ТипСправочника;
			КонецЕсли; 
	СтрЗнч = Стр.Строки.Добавить();
	СтрЗнч.Позиция = ТЧ.Позиция;
	СтрЗнч.ВидЭлемента = ТЧ.ВидМПЗ;
	СтрЗнч.МПЗ = ТЧ.МПЗ;
	СтрЗнч.Количество = ТЧ.Количество;
	СтрЗнч.ЕдиницаИзмерения = ТЧ.ЕдиницаИзмерения;
	СтрЗнч.Аналог = ТЧ.Аналог;
	СтрЗнч.Примечание = ТЧ.Примечание;
		Если ТЧ.Владелец <> Неопределено Тогда
		СтрЗнч.Владелец = ТЧ.Владелец.Элемент;
		КонецЕсли; 		 
	КонецЦикла;
ЗначениеВРеквизитФормы(тДерево, "ДеревоСпецификации");
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаКомплектацииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
ЗаполнитьДерево(Элемент.ТекущиеДанные.ЭтапСпецификации);
РазвернутьДерево(Неопределено);
КонецПроцедуры

&НаСервере
Процедура ПолучитьСпецификациюЭтапов(РабочееМесто)
СписокЭтапов = Новый СписокЗначений;

	Для каждого ТЧ Из Этапы Цикл
	ЭтапРМ = РабочееМесто.ТабличнаяЧасть.Найти(ТЧ.ГруппаНоменклатуры,"ГруппаНоменклатуры");
		Если ЭтапРМ = Неопределено Тогда
		Продолжить;
		КонецЕсли;
			Если ЭтапРМ.Комплектация Тогда
			ОбщийМодульВызовСервера.ПолучитьКомплектацию(ТЧ.ЭтапСпецификации,ТЧ.ЭтапСпецификации,ТЧ.Количество,Истина,ТаблицаКомплектации,Объект.ПроизводственноеЗадание.ДатаЗапуска);
			Иначе
			ОбщийМодульВызовСервера.ПолучитьКомплектацию(ТЧ.ЭтапСпецификации,ТЧ.ЭтапСпецификации,ТЧ.Количество,Ложь,ТаблицаКомплектации,Объект.ПроизводственноеЗадание.ДатаЗапуска);
			Выборка = ТаблицаКомплектации.НайтиСтроки(Новый Структура("ЭтапСпецификации",ТЧ.ЭтапСпецификации));
				Если Выборка.Количество() = 0 Тогда	
				ТЧТК = ТаблицаКомплектации.Добавить();
				ТЧТК.ЭтапСпецификации = ТЧ.ЭтапСпецификации;
				КонецЕсли;
			СписокЭтапов.Добавить(ТЧ.ЭтапСпецификации);
			ОбщийМодульВызовСервера.ПолучитьСпецификациюСАналогами(Объект.Спецификация,Объект.ПроизводственноеЗадание,ТЧ.ЭтапСпецификации,ТЧ.ЭтапСпецификации,ТЧ.Количество);	
			КонецЕсли; 	
	КонецЦикла;
ТаблицаКомплектации.Сортировать("Компл,ЭтапСпецификации,ВидЭлемента,Комплектация");
Объект.Спецификация.Сортировать("ЭтапСпецификации,ВидМПЗ,Позиция,МПЗ");
	Если ТаблицаКомплектации.Количество() = 0 Тогда
    ТЧТК = ТаблицаКомплектации.Добавить();
	ТЧТК.ЭтапСпецификации = СписокЭтапов[0].Значение;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ЗакрытьПредыдущееРабочееМесто(ПредыдущееРабочееМесто)
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	ДатаПоступления = ТекущаяДата();
	ЭПЗ = РегистрыСведений.ЭтапыПроизводственныхЗаданий.ПолучитьПоследнее(,Новый Структура("ПЗ",Объект.ПроизводственноеЗадание));
		Если ЭПЗ.РабочееМесто = ПредыдущееРабочееМесто Тогда
		НаборЗаписей = РегистрыСведений.СтендовыйПрогон.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ПЗ.Установить(Объект.ПроизводственноеЗадание);
		НаборЗаписей.Прочитать();
		    Для Каждого Запись Из НаборЗаписей Цикл
				Если Не ЗначениеЗаполнено(Запись.ДатаСнятия) Тогда
				Запись.ИсполнительСнятие = ПредыдущееРабочееМесто.Стенд.Исполнитель;
				Запись.ДатаСнятия = ДатаПоступления;
				Прервать; 
				КонецЕсли;  
		    КонецЦикла;
		НаборЗаписей.Записать();

		НаборЗаписей = РегистрыСведений.ЭтапыПроизводственныхЗаданий.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ПЗ.Установить(Объект.ПроизводственноеЗадание);
		НаборЗаписей.Прочитать();
		    Для Каждого Запись Из НаборЗаписей Цикл 
		    	Если Запись.РабочееМесто = ПредыдущееРабочееМесто Тогда
					Если Не ЗначениеЗаполнено(Запись.ДатаОкончания) Тогда
					Запись.Исполнитель = ПредыдущееРабочееМесто.Стенд.Исполнитель;
					Запись.ДатаОкончания = ДатаПоступления;					
					КонецЕсли; 
				Прервать;
				КонецЕсли;  
		    КонецЦикла;
		ЭПЗ = НаборЗаписей.Добавить();
		ЭПЗ.Период = ДатаПоступления;
		ЭПЗ.ПЗ = Объект.ПроизводственноеЗадание; 
		ЭПЗ.Линейка = Объект.ПроизводственноеЗадание.Линейка;
		ЭПЗ.Изделие = Объект.ПроизводственноеЗадание.Изделие;
		ЭПЗ.Количество = 1;
		ЭПЗ.БарКод = Объект.ПроизводственноеЗадание.БарКод;
		ЭПЗ.РабочееМесто = Объект.РабочееМесто;
		ЭПЗ.Исполнитель = Объект.Исполнитель;
		ЭПЗ.ДатаНачала = ДатаПоступления;
		НаборЗаписей.Записать();
		ПолучитьСпецификациюЭтапов(ПредыдущееРабочееМесто);
			Если Не ОбщийМодульСозданиеДокументов.СоздатьВыпускПродукции(Объект.ПроизводственноеЗадание,ПредыдущееРабочееМесто,Объект.Спецификация,Этапы,ДатаПоступления) Тогда
			Сообщить("Документ выпуска по производственному заданию "+Объект.ПроизводственноеЗадание.Номер+" не создан!");
			ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
			Возврат(Ложь);
			КонецЕсли;
		КонецЕсли; 
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Возврат(Истина);
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь);
	КонецПопытки;
КонецФункции

&НаСервере
Функция ПолучитьЗаданиеНаСервере(БарКод)
Результ = Новый Структура("ПЗ,РабочееМесто,Ремонт",Документы.ПроизводственноеЗадание.ПустаяСсылка(),Справочники.РабочиеМестаЛинеек.ПустаяСсылка(),Ложь);
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.РабочееМесто,
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.Ремонт
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПоследних(, ) КАК ЭтапыПроизводственныхЗаданийСрезПоследних
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПоследних.БарКод = &БарКод
	|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";	
Запрос.УстановитьПараметр("БарКод",БарКод);
Результат = Запрос.Выполнить();
Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
	Результ.ПЗ = Выборка.ПЗ;
	Результ.РабочееМесто = Выборка.РабочееМесто;
	Результ.Ремонт = Выборка.Ремонт;
	Объект.ПроизводственноеЗадание = Выборка.ПЗ;	
	КонецЦикла;
Возврат(Результ);
КонецФункции

&НаСервере
Функция ПолучитьЛинейку(ПЗ)
Возврат(ПЗ.Линейка);
КонецФункции

&НаСервере
Процедура ЗаполнитьЭтапПЗ()
Парам = Новый Структура("РабочееМесто,Исполнитель,ДатаНачала",Объект.РабочееМесто,Объект.Исполнитель,ТекущаяДата());
ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(Объект.ПроизводственноеЗадание,Парам);
КонецПроцедуры
 
&НаСервере
Функция МожноРаботатьВАРМ(РабочееМесто)
	Если ОбщийМодульВызовСервера.МожноВыполнить(РабочееМесто.Линейка) Тогда	
	Возврат(Истина);
	Иначе
	Сообщить("Работа АРМ запрещена в этой базе!");
	Возврат(Ложь);
	КонецЕсли;
КонецФункции 

&НаСервере
Функция СоздатьТаблицуЭП(ПЗ)
Возврат(ОбщийМодульВызовСервера.СоздатьТаблицуЭтаповПроизводства(ПЗ,Этапы,ЭтапыАРМ,Объект.РабочееМесто,Объект.Исполнитель));
КонецФункции 
             
&НаКлиенте
Процедура ПолучитьЗадание(Команда,БарКод = "")
	Если Не ЗначениеЗаполнено(БарКод) Тогда
		Если Не ВвестиСтроку(БарКод,"Введите бар-код",18) Тогда
		Возврат;
		КонецЕсли; 
	КонецЕсли;
Состояние("Обработка...",,"Получение задания...");
Результат = ПолучитьЗаданиеНаСервере(БарКод); 
	Если Не Результат.ПЗ.Пустая() Тогда
		Если Не МожноРаботатьВАРМ(Результат.РабочееМесто) Тогда
		Возврат;
		КонецЕсли;
			Если ОбщийМодульВызовСервера.ЛинейкаОстановлена(ПолучитьЛинейку(Результат.ПЗ)) Тогда
			Возврат;
			КонецЕсли;
				Если ОбщийМодульВызовСервера.МТКОстановлена(Результат.ПЗ) Тогда	
				Сообщить("По выбранному производственному заданию остановлена МТК!");
				Возврат;		
				КонецЕсли;
					Если Результат.Ремонт Тогда
					Сообщить("Изделие находится в ремонте!");
					Возврат;
					КонецЕсли;
	Объект.РабочееМесто = ОбщийМодульВызовСервера.ПолучитьРабочееМестоВЛинейке(ПолучитьЛинейку(Результат.ПЗ),"Упаковка");
	ПредыдущееРабочееМесто = ОбщийМодульВызовСервера.ПолучитьПредыдущееРабочееМесто(Объект.РабочееМесто);
		Если Результат.РабочееМесто = ПредыдущееРабочееМесто Тогда
		//Объект.ПроизводственноеЗадание = Результат.ПЗ;
			Если Не СоздатьТаблицуЭП(Результат.ПЗ) Тогда	
			Сообщить("МТК остановлена! Ошибка записана в МТК!");
			Возврат;			
			КонецЕсли;
		 		Если Не ЗакрытьПредыдущееРабочееМесто(ПредыдущееРабочееМесто) Тогда
				ОчиститьСсылкуНаПЗ();
				Возврат;
				КонецЕсли;				
		ИначеЕсли Результат.РабочееМесто = Объект.РабочееМесто Тогда	
		//Объект.ПроизводственноеЗадание = Результат.ПЗ;		
			Если Не СоздатьТаблицуЭП(Результат.ПЗ) Тогда	
			Сообщить("МТК остановлена! Ошибка записана в МТК!");
			Возврат;			
			КонецЕсли;
		ЗаполнитьЭтапПЗ();
		Иначе
		Сообщить("Изделие находится на этапе "+СокрЛП(Результат.РабочееМесто)+"!");
		Возврат;
		КонецЕсли;
	Иначе
	Сообщить("По данному бар-коду все этапы производства завершены!");
	Возврат;
	КонецЕсли; 		
Объект.Спецификация.Очистить();
ТаблицаКомплектации.Очистить();
ПолучитьСпецификациюЭтапов(Объект.РабочееМесто);
	Если ТипЗнч(ТаблицаКомплектации[0].Комплектация) = Тип("СправочникСсылка.Номенклатура") Тогда
	Элементы.ТаблицаКомплектации.ТекущаяСтрока = ТаблицаКомплектации[0].ПолучитьИдентификатор();
	ТаблицаКомплектацииВыборЗначения(Элементы.ТаблицаКомплектации,Элементы.ТаблицаКомплектации.ТекущаяСтрока,Истина);
	КонецЕсли;
ОткрытьФорму("Обработка.СозданныеБарКоды.Форма.Форма",Новый Структура("ПЗ,РабочееМесто",Объект.ПроизводственноеЗадание,Объект.РабочееМесто));
Элементы.Завершить.КнопкаПоУмолчанию = Истина;
Элементы.ПолучитьЗадание.Доступность = Ложь;
Элементы.ПечатьДокументов.Доступность = Истина;
Элементы.ПечатьКР.Доступность = Истина;
Элементы.Завершить.Доступность = Истина;
Элементы.Ремонт.Доступность = Истина;
СписокФайлов = ПолучитьФайлыДокументовДляПечати();
	Если СписокФайлов.Количество() > 0 Тогда
	Элементы.ПечатьКР.Доступность = Истина;
	Иначе	
	Элементы.ПечатьКР.Доступность = Ложь;
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПолучитьВидРемонтаОбщий()
Возврат(Перечисления.ВидыРемонта.Общий);
КонецФункции

&НаСервере
Функция ПолучитьИзделиеРемонта()
	Для каждого ТЧ_Этап Из Этапы Цикл
	ЭтапАРМ = Объект.РабочееМесто.ТабличнаяЧасть.Найти(ТЧ_Этап.ГруппаНоменклатуры,"ГруппаНоменклатуры");
		Если ЭтапАРМ = Неопределено Тогда
		Продолжить;
		ИначеЕсли ЭтапАРМ.Комплектация Тогда
	    Продолжить;
		КонецЕсли;
			Если ТЧ_Этап.ЭтапСпецификации.Виртуальный Тогда
			Продолжить;
			КонецЕсли;
	Возврат(Новый Структура("Изделие,Количество",ТЧ_Этап.ЭтапСпецификации,ТЧ_Этап.Количество));
	КонецЦикла;
КонецФункции

&НаКлиенте
Процедура Ремонт(Команда)
НомерВТ = "";
	Если Не ВвестиСтроку(НомерВТ,"Введите номер возвратной тары",4) Тогда
	Сообщить("Номер возвратной тары не введён!");
	Возврат;
	КонецЕсли;
Результат = ОткрытьФормуМодально("ОбщаяФорма.ВыборПричинРемонта",Новый Структура("РабочееМесто",Объект.РабочееМесто));
	Если Результат <> Неопределено Тогда
		Если ОбщийМодульСозданиеДокументов.СоздатьРемонтнуюКарту(Объект.ПроизводственноеЗадание,Объект.РабочееМесто,ПолучитьИзделиеРемонта(),Объект.Исполнитель,ПолучитьВидРемонтаОбщий(),Результат,,НомерВТ) Тогда
		ОчиститьСсылкуНаПЗ();
		КонецЕсли; 
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Процедура ОчиститьСсылкуНаПЗ()
Объект.РабочееМесто = Справочники.РабочиеМестаЛинеек.ПустаяСсылка();
Объект.ПроизводственноеЗадание = Документы.ПроизводственноеЗадание.ПустаяСсылка();
Этапы.Очистить();
ЭтапыАРМ.Очистить();
ТаблицаКомплектации.Очистить();
Объект.Спецификация.Очистить();
тДерево = РеквизитФормыВЗначение("ДеревоСпецификации");
тДерево.Строки.Очистить();
ЗначениеВРеквизитФормы(тДерево,"ДеревоСпецификации");
Элементы.ПолучитьЗадание.КнопкаПоУмолчанию = Истина;
Элементы.ПолучитьЗадание.Доступность = Истина;
Элементы.ПечатьДокументов.Доступность = Ложь;
Элементы.ПечатьКР.Доступность = Ложь;
Элементы.Завершить.Доступность = Ложь;
Элементы.Ремонт.Доступность = Ложь;
флПечать = Ложь;
КонецПроцедуры  

&НаКлиенте
Процедура РабочееМестоПриИзменении(Элемент)
ОчиститьСсылкуНаПЗ();
КонецПроцедуры

&НаСервере
Функция ЗавершитьЗаданиеНаСервере()
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	Парам = Новый Структура("РабочееМесто,ДатаОкончания",Объект.РабочееМесто,ТекущаяДата());
	ОбщийМодульРаботаСРегистрами.ИзменитьЭтапПроизводственногоЗадания(Объект.ПроизводственноеЗадание,Парам);
		Если Не ОбщийМодульСозданиеДокументов.СоздатьВыпускПродукции(Объект.ПроизводственноеЗадание,Объект.РабочееМесто,Объект.Спецификация,Этапы,ТекущаяДата()) Тогда
		Сообщить("Документ выпуска не создан!");
		ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
		Возврат(Ложь);
		КонецЕсли;
			Если Объект.ПроизводственноеЗадание.ДокументОснование.МестоХраненияПотребитель.Пустая() Тогда
			МестоПередачи = "на склад линейки";
			Иначе	
			МестоПередачи = "на склад "+СокрЛП(Объект.ПроизводственноеЗадание.ДокументОснование.МестоХраненияПотребитель.Наименование);
			КонецЕсли;		
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Возврат(МестоПередачи);
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат("");
	КонецПопытки;
КонецФункции

&НаСервере
Функция ПЗНаИспытаниях()
Возврат(Объект.ПроизводственноеЗадание.Испытания);
КонецФункции

&НаКлиенте
Процедура ЗавершитьЗадание(Команда)
	Если ОбщийМодульВызовСервера.ЛинейкаОстановлена(ПолучитьЛинейку(Объект.ПроизводственноеЗадание)) Тогда
	Возврат;
	КонецЕсли;
		Если Не ОбщийМодульВызовСервера.МТКОстановлена(Объект.ПроизводственноеЗадание) Тогда
		МестоПередачи = ЗавершитьЗаданиеНаСервере();
			Если МестоПередачи <> "" Тогда
			Испытания = ПЗНаИспытаниях();
				Если Испытания = 1 Тогда
				Предупреждение("Отложите изделие для ПСИ!",,"Внимание!");
				ИначеЕсли Испытания = 2 Тогда
				Предупреждение("Отложите изделие для поверки!",,"Внимание!");
				Иначе
				ПоказатьОповещениеПользователя("ВНИМАНИЕ!",,"Передайте изделие "+МестоПередачи,БиблиотекаКартинок.Пользователь);
				КонецЕсли;
			ОчиститьСсылкуНаПЗ();
			КонецЕсли;
		Иначе
		ОчиститьСсылкуНаПЗ();
		Сообщить("По выбранному производственному заданию остановлена МТК!");
		КонецЕсли;  
КонецПроцедуры

&НаСервере
Функция ЭтоПереупаковка(РабочееМесто)
	Если РабочееМесто.Линейка.ВидЛинейки = Перечисления.ВидыЛинеек.Переупаковка Тогда
	Возврат(Истина);
	Иначе	
	Возврат(Ложь);
	КонецЕсли; 
КонецФункции

&НаКлиенте
Процедура РабочееМестоОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Если ЭтоПереупаковка(ВыбранноеЗначение) Тогда
	Сообщить("Выберите рабочее место из основной или проектной линейки!");
	СтандартнаяОбработка = Ложь;
	Возврат;
	КонецЕсли; 
		Если Не Объект.ПроизводственноеЗадание.Пустая() Тогда
			Если Вопрос("Задание не завершено. Вы действительно хотите авторизоваться?",РежимДиалогаВопрос.ДаНет,,,"ВНИМАНИЕ!") = КодВозвратаДиалога.Нет Тогда
			СтандартнаяОбработка = Ложь;
			КонецЕсли; 
		КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПолучитьСписокЭтапов()
СписокЭтапов = Новый СписокЗначений;
	Для каждого ТЧ Из ТаблицаКомплектации Цикл
		Если СписокЭтапов.НайтиПоЗначению(ТЧ.ЭтапСпецификации) = Неопределено Тогда
		СписокЭтапов.Добавить(ТЧ.ЭтапСпецификации);
		КонецЕсли; 
	КонецЦикла;
Возврат(СписокЭтапов);
КонецФункции 

&НаСервере
Функция ЭтоКомплект()
Возврат(Объект.ПроизводственноеЗадание.Изделие.Товар.Комплект);
КонецФункции

&НаКлиенте
Процедура ПечатьДокументов(Команда)
	Если флПечать Тогда
		Если Вопрос("Распечатать повторно?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Нет Тогда
		Возврат;
		КонецЕсли; 
	КонецЕсли;
		Если ЭтоКомплект() Тогда
		СписокКомплект = ОткрытьФормуМодально("Обработка.РабочееМестоУпаковка.Форма.СоставКомплекта");
			Если СписокКомплект <> Неопределено Тогда
			ОткрытьФорму("Обработка.СозданныеБарКоды.Форма.Форма",Новый Структура("ПЗ,РабочееМесто,ДатаВыпуска,Комплект",Объект.ПроизводственноеЗадание,Объект.РабочееМесто,ТекущаяДата(),СписокКомплект)); 
			флПечать = Истина;
			КонецЕсли;		
		Иначе	
		Результат = ОткрытьФормуМодально("Обработка.РабочееМестоУпаковка.Форма.ФормаВыбораДатПечати",Новый Структура("ПЗ,ИзменитьПоМаске",Объект.ПроизводственноеЗадание,ИзменитьПоМаске));
			Если Результат <> Неопределено Тогда
			ОткрытьФорму("Обработка.СозданныеБарКоды.Форма.Форма",Новый Структура("ПЗ,РабочееМесто,ДатаВыпуска,ДатаПоверки",Объект.ПроизводственноеЗадание,Объект.РабочееМесто,Результат.ДатаВыпуска,Результат.ДатаПоверки));
			КонецЕсли;
		флПечать = Истина;
		КонецЕсли;  
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьДерево(Команда)
тЭлементы = ДеревоСпецификации.ПолучитьЭлементы();
   Для Каждого тСтр Из тЭлементы Цикл
   	Элементы.ДеревоСпецификации.Развернуть(тСтр.ПолучитьИдентификатор(), Истина);
   КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СвернутьДерево(Команда)
тЭлементы = ДеревоСпецификации.ПолучитьЭлементы();
   Для Каждого тСтр Из тЭлементы Цикл
   Элементы.ДеревоСпецификации.Свернуть(тСтр.ПолучитьИдентификатор());
   КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьДокумент(Команда)
	Если ТипЗнч(Элементы.ДеревоСпецификации.ТекущиеДанные.МПЗ) = Тип("СправочникСсылка.Документация") Тогда
	ОбщийМодульКлиент.ОткрытьФайлДокумента(Элементы.ДеревоСпецификации.ТекущиеДанные.МПЗ);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоСпецификацииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если ТипЗнч(Элементы.ДеревоСпецификации.ТекущиеДанные.МПЗ) = Тип("СправочникСсылка.Документация") Тогда
	ОбщийМодульКлиент.ОткрытьФайлДокумента(Элементы.ДеревоСпецификации.ТекущиеДанные.МПЗ);
	КонецЕсли;
КонецПроцедуры
    
&НаСервере
Функция ПолучитьМестоХранения(Линейка)
Возврат(Линейка.МестоХраненияКанбанов);
КонецФункции 

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	Если ЭтаФорма.ВводДоступен() Тогда
	Массив = ОбщийМодульВызовСервера.РазложитьСтрокуВМассив(Данные,";");
		Если Массив[0] = "3" Тогда
		ЗначениеПараметра1 = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[1]);
			Если ЗначениеПараметра1 = Неопределено Тогда
			Сообщить("Линейка или место хранения не найдена!");
			Возврат;	
			КонецЕсли; 
		МПЗ = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[3]);
			Если МПЗ = Неопределено Тогда
			Сообщить(Массив[3]+" - МПЗ не найдена!");
			Возврат;	
			КонецЕсли;
				Если ТипЗнч(ЗначениеПараметра1) = Тип("СправочникСсылка.Линейки") Тогда
				МестоХранения = ПолучитьМестоХранения(ЗначениеПараметра1);
				Иначе
				МестоХранения = ЗначениеПараметра1;			
				КонецЕсли;
		МестоХраненияОтправитель = ОбщийМодульВызовСервера.ПолучитьМестоХраненияПоКоду(Массив[2]);
		П = Новый Структура("МестоХраненияОтправитель,МестоХраненияКанбанов,МПЗ,НомерЯчейки,Сотрудник",МестоХраненияОтправитель,МестоХранения,МПЗ,Массив[5],Объект.Исполнитель);
		ОткрытьФорму("ОбщаяФорма.ОформлениеПустыхКанбанов",П,,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		Иначе 
			Если Элементы.ПолучитьЗадание.Доступность Тогда
			ПолучитьЗадание(Неопределено,Данные);
			Иначе
			Сообщить("Завершите предыдущее задание!"); 	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаКомплектацииВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
ЗаполнитьДерево(Элемент.ТекущиеДанные.ЭтапСпецификации);
РазвернутьДерево(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура ОформитьНедостачу(Команда)
	Если ОбщийМодульАРМКлиент.ОформитьНедостачу(ЭтаФорма,Объект.РабочееМесто,Объект.ПроизводственноеЗадание) Тогда
	ОчиститьСсылкуНаПЗ();
	КонецЕсли; 
КонецПроцедуры 
           
&НаСервере 
Функция ПолучитьФайлыДокументовДляПечати()
Возврат(ОбщийМодульВызовСервера.ПолучитьФайлыДокументовДляПечати(Объект.Спецификация));
КонецФункции

&НаКлиенте
Процедура ПечатьКР(Команда)
ОбщийМодульАРМКлиент.ПечатьДокументовА4(ПолучитьФайлыДокументовДляПечати());
КонецПроцедуры
