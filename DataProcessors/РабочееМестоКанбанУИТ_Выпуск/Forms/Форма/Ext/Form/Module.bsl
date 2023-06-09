﻿
&НаСервере
Процедура ПриСозданииНаСервере()
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
		Если Не Объект.РабочееМесто.Пустая() Тогда
		РабочееМестоПриИзменении(Неопределено);
		КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры

&НаСервере
Функция ПроверитьЛОПотребителя(Изделие,МестоХраненияКанбанов)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ЛьготнаяОчередьСрезПоследних.ПЗ
	|ИЗ
	|	РегистрСведений.ЛьготнаяОчередь.СрезПоследних КАК ЛьготнаяОчередьСрезПоследних
	|ГДЕ
	|	ЛьготнаяОчередьСрезПоследних.НормаРасходов.Элемент = &МПЗ
	|	И ЛьготнаяОчередьСрезПоследних.Линейка.МестоХраненияКанбанов = &МестоХраненияКанбанов
	|	И ЛьготнаяОчередьСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("МПЗ", Изделие);
Запрос.УстановитьПараметр("МестоХраненияКанбанов", МестоХраненияКанбанов);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Возврат(Истина);
	КонецЦикла;
Возврат(Ложь);
КонецФункции

&НаСервере
Функция ПроверитьЛО(Изделие)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ЛьготнаяОчередьСрезПоследних.ПЗ
	|ИЗ
	|	РегистрСведений.ЛьготнаяОчередь.СрезПоследних КАК ЛьготнаяОчередьСрезПоследних
	|ГДЕ
	|	ЛьготнаяОчередьСрезПоследних.Изделие = &Изделие
	|	И ЛьготнаяОчередьСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("Изделие", Изделие);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Возврат(Истина);
	КонецЦикла;
Возврат(Ложь);
КонецФункции

&НаСервере
Процедура ПолучитьДанныеНаСервере()
Объект.ТаблицаПЗ.Очистить();
Запрос = Новый Запрос;

КодРабочегоМеста = ПолучитьКодРабочегоМеста();
	Если КодРабочегоМеста = 4 Тогда
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ,
		|	ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаОкончания,
		|	ЭтапыПроизводственныхЗаданийСрезПоследних.Период КАК Период
		|ИЗ
		|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПоследних КАК ЭтапыПроизводственныхЗаданийСрезПоследних
		|ГДЕ
		|	ЭтапыПроизводственныхЗаданийСрезПоследних.РабочееМесто = &РабочееМесто
		|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ПЗ.ДокументОснование.Статус <> 3
		|	И ЭтапыПроизводственныхЗаданийСрезПоследних.ДатаОкончания <> ДАТАВРЕМЯ(1,1,1,0,0,0)";
	Иначе
	Сообщить("Выберите последнее рабочее место!");
	Возврат;
	КонецЕсли;
Запрос.УстановитьПараметр("РабочееМесто",Объект.РабочееМесто);
Результат = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = Результат.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	ТЧ = Объект.ТаблицаПЗ.Добавить();
	ТЧ.Потребитель = ВыборкаДетальныеЗаписи.ПЗ.ДокументОснование.МестоХраненияПотребитель;
	ТЧ.ПроизводственноеЗадание = ВыборкаДетальныеЗаписи.ПЗ;
	ТЧ.Изделие = ВыборкаДетальныеЗаписи.ПЗ.Изделие;
	ТЧ.ДатаОкончания = ВыборкаДетальныеЗаписи.ДатаОкончания;
	ТЧ.ЛО = ПроверитьЛО(ТЧ.Изделие);
	ТЧ.ЛОПотребителя = ПроверитьЛОПотребителя(ТЧ.Изделие,ТЧ.Потребитель);
	ТЧ.КоличествоНаСкладеГП = ОбщийМодульРаботаСРегистрами.ПолучитьОстатокПоМестуХранения(Объект.РабочееМесто.Линейка.МестоХраненияГП,ТЧ.Изделие);
	КонецЦикла;
Объект.ТаблицаПЗ.Сортировать("ДатаОкончания");
КонецПроцедуры
 
&НаКлиенте
Процедура ПолучитьДанные() Экспорт
ПолучитьДанныеНаСервере();
КонецПроцедуры

&НаСервере
Функция ПолучитьКодРабочегоМеста()
Возврат(Объект.РабочееМесто.Код);
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
ПолучитьДанныеНаСервере();
	Если Объект.ИнтервалОбновления > 0 Тогда
	ПодключитьОбработчикОжидания("ПолучитьДанные", Объект.ИнтервалОбновления*60);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
ПолучитьДанныеНаСервере();
КонецПроцедуры

&НаСервере
Функция ЗавершитьНаСервере(Стр)
ТЧ = Объект.ТаблицаПЗ.НайтиПоИдентификатору(Стр);
ПЗ = ТЧ.ПроизводственноеЗадание;
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
		Если Не ОбщийМодульСозданиеДокументов.СоздатьВыпускПродукцииКанбан(ПЗ,ТекущаяДата()) Тогда
		Сообщить("Документ выпуска по ПЗ "+ПЗ.Номер+" не создан!");
		ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
		Возврат(Ложь);
		КонецЕсли;
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Объект.ТаблицаПЗ.Удалить(ТЧ);
	Возврат(Истина);	
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь);
	КонецПопытки;
КонецФункции

&НаКлиенте
Процедура Завершить(Команда)
	Если Элементы.ТаблицаПЗ.ТекущаяСтрока <> Неопределено Тогда
		Если Не ОбщийМодульВызовСервера.МТКОстановлена(Элементы.ТаблицаПЗ.ТекущиеДанные.ПроизводственноеЗадание) Тогда
		ЗавершитьНаСервере(Элементы.ТаблицаПЗ.ТекущаяСтрока);
		Иначе
		Сообщить("По выбранному производственному заданию остановлена МТК!");
		КонецЕсли;	
	Иначе
	Сообщить("Выберите производственное задание!");
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ЗавершитьСПередачейНаЛинейкуНаСервере(Стр)
ТЧ = Объект.ТаблицаПЗ.НайтиПоИдентификатору(Стр);
ПЗ = ТЧ.ПроизводственноеЗадание;
ДатаОкончания = ТекущаяДата();
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
		Если Не ОбщийМодульСозданиеДокументов.СоздатьВыпускПродукцииКанбан(ПЗ,ДатаОкончания) Тогда
		Сообщить("Документ выпуска по ПЗ "+ПЗ.Номер+" не создан!");
		ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
		Возврат(Ложь);
		КонецЕсли;
			Если ПЗ.ДокументОснование.НомерЯчейки > 0 Тогда
				Если Не ОбщийМодульСозданиеДокументов.СоздатьПередачуНаЛинейку(ПЗ.ДокументОснование,ДатаОкончания+1) Тогда
				Сообщить("Документ передачи на линейку не создан!");
				ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
				Возврат(Ложь);				
				КонецЕсли; 
			КонецЕсли;			
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Объект.ТаблицаПЗ.Удалить(ТЧ);
	Возврат(Истина);	
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь);
	КонецПопытки;
КонецФункции

&НаКлиенте
Процедура ЗавершитьСПередачейНаЛинейку(Команда)
	Если Элементы.ТаблицаПЗ.ТекущаяСтрока <> Неопределено Тогда
		Если Не ОбщийМодульВызовСервера.МТКОстановлена(Элементы.ТаблицаПЗ.ТекущиеДанные.ПроизводственноеЗадание) Тогда
		ЗавершитьСПередачейНаЛинейкуНаСервере(Элементы.ТаблицаПЗ.ТекущаяСтрока);
		Иначе
		Сообщить("По выбранному производственному заданию остановлена МТК!");
		КонецЕсли;	
	Иначе
	Сообщить("Выберите производственное задание!");
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОбновленияПриИзменении(Элемент)
ОтключитьОбработчикОжидания("ПолучитьДанные");
	Если Объект.ИнтервалОбновления > 0 Тогда
	ПодключитьОбработчикОжидания("ПолучитьДанные", Объект.ИнтервалОбновления*60);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция НайтиПЗ(Данные)
Массив = ОбщийМодульВызовСервера.РазложитьСтрокуВМассив(Данные,";");
	Если Массив[0] = "3" Тогда
	МестоХраненияПотребитель = ЗначениеИзСтрокиВнутр(Массив[1]);
	Спецификация = ЗначениеИзСтрокиВнутр(Массив[3]);
	НомерЯчейки = Число(Массив[5]);
		Для каждого ТЧ Из Объект.ТаблицаПЗ Цикл
			Если ТЧ.ПроизводственноеЗадание.ДокументОснование.МестоХраненияПотребитель = МестоХраненияПотребитель Тогда	
				Если ТЧ.ПроизводственноеЗадание.Изделие = Спецификация Тогда
					Если ТЧ.ПроизводственноеЗадание.ДокументОснование.НомерЯчейки = НомерЯчейки Тогда
					Возврат(ТЧ.ПолучитьИдентификатор());
					КонецЕсли; 
				КонецЕсли; 	
		    КонецЕсли;
		КонецЦикла;
	Иначе
	МТК = ЗначениеИзСтрокиВнутр(Массив[0]);
		Для каждого ТЧ Из Объект.ТаблицаПЗ Цикл
			Если ТЧ.ПроизводственноеЗадание.ДокументОснование = МТК Тогда	
			Возврат(ТЧ.ПолучитьИдентификатор()); 	
		    КонецЕсли;
		КонецЦикла;
	КонецЕсли; 
Возврат(Неопределено);
КонецФункции

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	Если ЭтаФорма.ВводДоступен() Тогда
	ВыбСтрока = НайтиПЗ(Данные);
		Если ВыбСтрока <> Неопределено Тогда
		Элементы.ТаблицаПЗ.ТекущаяСтрока = ВыбСтрока;
		Иначе	
		Сообщить("Производственное задание не найдено!");
		КонецЕсли;
	КонецЕсли; 
КонецПроцедуры
