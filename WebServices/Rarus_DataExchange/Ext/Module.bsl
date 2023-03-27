﻿
#Область ПрограммныйИнтерфейс

Функция ВыгрузитьОбъект(Параметры)
    УстановитьПривилегированныйРежим(Истина);
	Результат = Новый Структура("ЕстьОшибки, СообщениеОбОшибке, КонечноеСообщение", Ложь, "", "Данные выгружены в учетную систему");
	
	ПараметрыДанных = Параметры.Получить();
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(ПараметрыДанных.СтрокаХМЛ);
	
	попытка
	ВосстановленныйОбъект = ПрочитатьXML(ЧтениеXML);
	//очищаем движения удаляемого дока ++
	Если ТипЗнч(ВосстановленныйОбъект) = Тип("УдалениеОбъекта") тогда
	    ИмяОбъекта = ВосстановленныйОбъект.Ссылка.Метаданные().ПолноеИмя();
		СтрокаСсылка = Строка(ВосстановленныйОбъект.Ссылка);
		СсылкаНайдена = Найти(СтрокаСсылка,"Object not found") = 0 И Найти(СтрокаСсылка,"Объект не найден") = 0;
		Если Найти(ИмяОбъекта,"Документ.")> 0 И СсылкаНайдена тогда
			Движения = ВосстановленныйОбъект.Ссылка.ПолучитьОбъект().Движения;
			Для каждого Набор из Движения цикл
				Набор.Очистить();
				Набор.Записать();
			КонецЦикла;
		КонецЕсли;
		//очищаем движения удаляемого дока --
	Иначе
		//удаляем движения у не проведенных доков++
		ИмяОбъекта = ВосстановленныйОбъект.Метаданные().ПолноеИмя();
		Если Найти(ИмяОбъекта,"Документ.")> 0 И НЕ ВосстановленныйОбъект.Проведен тогда
			СтрокаСсылка = Строка(ВосстановленныйОбъект.Ссылка);
			Если НЕ ПустаяСтрока(СтрокаСсылка) тогда
				Движения = ВосстановленныйОбъект.Движения;
				Для каждого Набор из Движения цикл
					Набор.Очистить();
					Набор.Записать();
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	//удаляем движения у не проведенных доков--
	
	ВосстановленныйОбъект.ОбменДанными.Загрузка = Истина;
	ВосстановленныйОбъект.Записать();
	исключение
		Результат.ЕстьОшибки = Истина;
		Результат.СообщениеОбОшибке = ОписаниеОшибки();
		Результат.КонечноеСообщение = "Ошибка в учетной системе при записи объекта";
	КонецПопытки;
	
	Если ПолучитьФункциональнуюОпцию("ИспользоватьКонтрольОбмена") И Результат.КонечноеСообщение = "Данные выгружены в учетную систему" тогда
		ЧтоЭто = Строка(ТипЗнч(ВосстановленныйОбъект));
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Information register Record set","Регистр сведений набор записей");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Document Object","Документ объект");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Catalog Object","Справочник объект");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Object deletion","Удаление объекта");
		Если Найти(ЧтоЭто,"Регистр накопления") = 0 И Найти(ЧтоЭто,"Accumulation register") = 0 И Найти(ЧтоЭто,"Контроль обмена по веб сервису") = 0 тогда
			Запись = РегистрыСведений.КонтрольОбменаПоВебСервису2.СоздатьМенеджерЗаписи();
			Запись.ИмяОбъекта = ЧтоЭто;
			Хеш = Новый ХешированиеДанных(ХешФункция.CRC32);
			Хеш.Добавить(ПараметрыДанных.СтрокаХМЛ);
			Запись.ХешСумма = Хеш.ХешСумма;
			Запись.КогдаПопалВБазу = ТекущаяДата();
			//записываем файл на диск
			ТекДок = Новый ТекстовыйДокумент();
			ТекДок.УстановитьТекст(ПараметрыДанных.СтрокаХМЛ);
			Каталог = Константы.КаталогЛогирования.Получить();
			Подкаталог = Строка(формат(Запись.КогдаПопалВБазу,"ДФ=dd.MM.yyyy"));
			Каталог = Каталог+"\КонтрольПриема\"+Подкаталог;
			ДляПроверки = Новый Файл(Каталог);
			Если НЕ ДляПроверки.Существует() тогда
			   СоздатьКаталог(Каталог);
			КонецЕсли;
			ПолноеИмяФайла = Каталог+"\"+Строка(Хеш.ХешСумма)+".xml";
			Если Найти(ЧтоЭто,"Регистр сведений") = 0 И Найти(ЧтоЭто,"Information register") = 0 тогда
				Запись.Ссылка = ВосстановленныйОбъект.Ссылка;
			КонецЕсли;	
			попытка
				ТекДок.Записать(ПолноеИмяФайла, "UTF-8");
			    Запись.ПутьКФайлу = ПолноеИмяФайла;
			исключение
			КонецПопытки;
			Запись.Записать();
		КонецЕсли;
	КонецЕсли;	
    УстановитьПривилегированныйРежим(Ложь);
	Возврат Новый ХранилищеЗначения(Результат, Новый СжатиеДанных(9)); 	
	
КонецФункции

Функция СравнитьБазы(Данные)
	УстановитьПривилегированныйРежим(Истина);
	ПараметрыДанных = Данные.Получить();
	Если ПараметрыДанных.Свойство("Регистрация") тогда
		МассивПолучателей = СРМ_ОбменВебСервис.ПолучитьМассивУзловПолучателей("ПланОбменаЛинейкаГлавная");
		ТЗДляРегистрации = ПараметрыДанных.ТЗДляРегистрации;
		//МассивДляРегистрации = ТЗДляРегистрации.ВыгрузитьКолонку("Ссылка");
		//
		//ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, МассивДляРегистрации);
		//регаем движения 
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗ.Ссылка КАК Ссылка,
		|	ТЗ.ВидДокумента КАК ВидДокумента
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ТЗ КАК ТЗ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ.Ссылка КАК Ссылка,
		|	ВТ.ВидДокумента КАК ВидДокумента
		|ИЗ
		|	ВТ КАК ВТ
		|ИТОГИ ПО
		|	ВидДокумента";
		
		Запрос.УстановитьПараметр("ТЗ",ТЗДляРегистрации);
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаВидДокумента = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаВидДокумента.Следующий() Цикл
			Движения = Метаданные.Документы[ВыборкаВидДокумента.ВидДокумента].Движения;
			МассивНаборов = Новый Массив;
			Для каждого СтрокаДвижения Из Движения цикл
				Попытка
					Набор = РегистрыНакопления[СтрокаДвижения.Имя].СоздатьНаборЗаписей();
				исключение 
					Набор = РегистрыСведений[СтрокаДвижения.Имя].СоздатьНаборЗаписей();
				КонецПопытки;
				МассивНаборов.Добавить(Набор);
			КонецЦикла;
			Выборка = ВыборкаВидДокумента.Выбрать();
			Пока Выборка.Следующий() цикл 
				ВыборкаСсылка = Выборка.Ссылка;
				ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, ВыборкаСсылка);
				Для каждого Набор из МассивНаборов цикл
					Набор.Отбор.Регистратор.ВидСравнения = ВидСравнения.Равно;
					Набор.Отбор.Регистратор.Значение = ВыборкаСсылка;
					Набор.Отбор.Регистратор.Использование = Истина;
					ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, Набор);
				КонецЦикла;	
			КонецЦикла;
		КонецЦикла;
		
		//Для Каждого Ссылка Из ПараметрыДанных.МассивДляРегистрации Цикл 
		//	Если Ссылка.Проведен тогда
		//		Об = Ссылка.ПолучитьОбъект();
		//		Для Каждого Набор Из Об.Движения Цикл
		//			ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, Набор);
		//		КонецЦикла;		
		//	КонецЕсли;
		//КонецЦикла;	
		Результат = "Регистрация в базе-приемнике выполнена успешно!";
	Иначе	
		Результат = Новый Структура("ЕстьОшибки, СообщениеОбОшибке, Объекты", Ложь, "", Неопределено);
		
		Запрос = Новый Запрос;
		Запрос.Текст = ПараметрыДанных.ТекстЗапроса;
		Для Каждого СтрокаПараметр Из ПараметрыДанных.ПараметрыЗапроса Цикл
			Запрос.УстановитьПараметр(СтрокаПараметр.ИмяПараметра, СтрокаПараметр.ЗначениеПараметра);
		КонецЦикла;
		Результат.Объекты = Запрос.Выполнить().Выгрузить();
	КонецЕсли; 
	УстановитьПривилегированныйРежим(Ложь); 
	Возврат Новый ХранилищеЗначения(Результат, Новый СжатиеДанных(9)); 	
КонецФункции

Функция ПолучитьБитыеСсылки(ДанныеОтбор)
	УстановитьПривилегированныйРежим(Истина);
	
	СтруктураВозврата = Новый Структура("БитыеСсылки", Неопределено);
	
	БитыеСсылки = ИщемБитыеСсылки();
	Если БитыеСсылки.Количество()>0 тогда
		КвалификаторыСтроки = Новый КвалификаторыСтроки(36);	
		БитыеСсылки.Колонки.Добавить("ЗначениеУИ", Новый ОписаниеТипов("Строка",,,,КвалификаторыСтроки));
		
		Для каждого Стр Из БитыеСсылки Цикл
			Стр.ЗначениеУИ = XMLСтрока(Стр.Объект);
		КонецЦикла;
		
		БитыеСсылки.Колонки.Удалить("Объект");
		
		СтруктураВозврата.БитыеСсылки = БитыеСсылки;
	КонецЕсли;
	УстановитьПривилегированныйРежим(Ложь);

	Возврат Новый ХранилищеЗначения(СтруктураВозврата, Новый СжатиеДанных(9));	
	
КонецФункции

Функция ОбменПослеСбоя(Параметры)
	УстановитьПривилегированныйРежим(Истина);
	ПараметрыДанных = Параметры.Получить();
	
	ФайлПриемник = ПараметрыДанных.ИмяФайла;
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ФайлПриемник);
	ЧтениеXML.Прочитать();
	ЧтениеXML.Прочитать();
	ЧтениеXML.Прочитать();
	Ошибки = Новый Массив;
	Пока СериализаторXDTO.ВозможностьЧтенияXML(ЧтениеXML) Цикл	
		попытка
			ВосстановленныйОбъект = СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
		исключение
			Ошибки.Добавить(Новый Структура("ИмяОбъекта, Хеш, Ошибка", "", 0,ОписаниеОшибки()));
			продолжить;
		КонецПопытки;
		ВосстановленныйОбъект.ОбменДанными.Загрузка = Истина;
		ЧтоЭто = Строка(ТипЗнч(ВосстановленныйОбъект));
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Information register Record set","Регистр сведений набор записей");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Document Object","Документ объект");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Catalog Object","Справочник объект");
		ЧтоЭто = СтрЗаменить(ЧтоЭто,"Object deletion","Удаление объекта");
		ЗаписьXML = Новый ЗаписьXML;
		ЗаписьXML.УстановитьСтроку();
		ЗаписьXML.ЗаписатьОбъявлениеXML();
		ЗаписатьXML(ЗаписьXML, ВосстановленныйОбъект, НазначениеТипаXML.Явное);
		СтрокаХМЛ = ЗаписьXML.Закрыть();
		Хеш = Новый ХешированиеДанных(ХешФункция.CRC32);
		Хеш.Добавить(СтрокаХМЛ);
		попытка
			ВосстановленныйОбъект.Записать();
			//пишем в контроль обмена
			Если ПолучитьФункциональнуюОпцию("ИспользоватьКонтрольОбмена") тогда
				Если Найти(ЧтоЭто,"Регистр накопления") = 0 И Найти(ЧтоЭто,"Accumulation register") = 0 И Найти(ЧтоЭто,"Контроль обмена по веб сервису") = 0 тогда
					Запись = РегистрыСведений.КонтрольОбменаПоВебСервису2.СоздатьМенеджерЗаписи();
					Запись.ИмяОбъекта = ЧтоЭто;
					Запись.ХешСумма = Хеш.ХешСумма;
					Запись.КогдаПопалВБазу = ТекущаяДата();
					Запись.ПутьКФайлу = "Загружен после сбоя";
					Если Найти(ЧтоЭто,"Регистр сведений") = 0 И Найти(ЧтоЭто,"Information register") = 0 тогда
						Запись.Ссылка = ВосстановленныйОбъект.Ссылка;
					КонецЕсли;	
					Запись.Записать();
				КонецЕсли;
			КонецЕсли;	
		исключение
			Ошибки.Добавить(Новый Структура("ИмяОбъекта, Хеш, Ошибка", ЧтоЭто, Хеш.ХешСумма,ОписаниеОшибки()));
		конецпопытки;
	КонецЦикла;	
	ЧтениеXML.Закрыть();
	
	УстановитьПривилегированныйРежим(Ложь);
	Возврат Новый ХранилищеЗначения(Новый Структура("Ошибки",Ошибки), Новый СжатиеДанных(9)); 	
КонецФункции

#КонецОбласти

Функция ИщемБитыеСсылки()
	РезультатПоиска = новый ТаблицаЗначений;
	РезультатПоиска.Колонки.Добавить("Объект");
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("Строка"));
	КвалификаторыСтроки = Новый КвалификаторыСтроки(100);
	ОписаниеСтрока = Новый ОписаниеТипов(МассивТипов,,,,КвалификаторыСтроки);
	РезультатПоиска.Колонки.Добавить("Реквизит", ОписаниеСтрока);

	НачалоД = НачалоДня(ТекущаяДата());
	КонецД = КонецДня(ТекущаяДата());
	Для Каждого ОбъектМетаданных Из Метаданные.Документы Цикл
			ПроверитьОбъектМетаданныхНаБитыеСсылки(ОбъектМетаданных, РезультатПоиска, НачалоД, КонецД);
	КонецЦикла;
	
	РезультатПоиска.Свернуть("Объект, Реквизит");	
	
	Возврат РезультатПоиска;
КонецФункции

Процедура ПроверитьОбъектМетаданныхНаБитыеСсылки(ОбъектМетаданных, РезультатПоиска, НачалоД, КонецД)
	ИмяТаблицы = ОбъектМетаданных.ПолноеИмя();
	ОтборПоДате = " И Об.Дата МЕЖДУ &НачалоД И &КонецД";
	АнализСвойствОбъекта(ОбъектМетаданных, ОбъектМетаданных.Реквизиты, ИмяТаблицы, РезультатПоиска, НачалоД, КонецД, ОтборПоДате);
	ОтборПоДате = " И Об.Ссылка.Дата МЕЖДУ &НачалоД И &КонецД";
	Для Каждого ТабЧасть Из ОбъектМетаданных.ТабличныеЧасти Цикл
		АнализСвойствОбъекта(ОбъектМетаданных, ТабЧасть.Реквизиты, ИмяТаблицы + "." + ТабЧасть.Имя, РезультатПоиска, НачалоД, КонецД, ОтборПоДате);
	КонецЦикла;
	
КонецПроцедуры

Процедура АнализСвойствОбъекта(ОбъектМетаданных, Свойства, ИмяТаблицы, РезультатПоиска, НачалоД, КонецД, ОтборПоДате)
	ТекстЗапроса = "";
	Для Каждого Реквизит Из Свойства Цикл
		Для Каждого моТип Из Реквизит.Тип.Типы() Цикл
			//ТекстЗапроса = "";
			МетаданныеТипа = Метаданные.НайтиПоТипу(моТип);
			Если МетаданныеТипа <> Неопределено И Не Метаданные.Перечисления.Содержит(МетаданныеТипа) Тогда
				ДобавитьВЗапросОбъект(ТекстЗапроса, ОбъектМетаданных, ИмяТаблицы, Реквизит.Имя, моТип, ОтборПоДате);
			КонецЕсли;
			//Если Не ПустаяСтрока(ТекстЗапроса) Тогда
			//	ВывестиДанные(ТекстЗапроса, РезультатПоиска, НачалоД, КонецД);
			//КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Если Не ПустаяСтрока(ТекстЗапроса) Тогда
		ВывестиДанные(ТекстЗапроса, РезультатПоиска, НачалоД, КонецД);
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьВЗапросОбъект(ТекстЗапроса, ОбъектМетаданных, ИмяТаблицы, ИмяРеквизита, ТипРеквизита, ОтборПоДате)
	
	Текст = "ВЫБРАТЬ Об." + ИмяРеквизита + " КАК Объект, 
			| 	" + ДобавитьОписаниеТипа(ИмяРеквизита, ТипРеквизита) + " 
			|ИЗ 
			|	" + ИмяТаблицы + " КАК Об
			|ГДЕ " + ДобавитьУсловия(ИмяРеквизита, ТипРеквизита) + ОтборПоДате;
	ТекстЗапроса = ТекстЗапроса + ?(ПустаяСтрока(ТекстЗапроса), "", Символы.ПС + "ОБЪЕДИНИТЬ ВСЕ" + Символы.ПС) + Текст;
	
КонецПроцедуры

Процедура ВывестиДанные(ТекстЗапроса, РезультатПоиска, НачалоД, КонецД)
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("НачалоД", НачалоД);
	Запрос.УстановитьПараметр("КонецД", КонецД);
	Попытка 
		РезультатЗапроса = Запрос.Выполнить();
		Если Не РезультатЗапроса.Пустой() Тогда
			ТЗ = РезультатЗапроса.Выгрузить();
			Для Каждого Стр Из ТЗ Цикл
				Если Найти(Стр.Реквизит, "Справочник") > 0 ИЛИ  Найти(Стр.Реквизит, "Документ") > 0 тогда
					Строка = РезультатПоиска.Добавить();
					ЗаполнитьЗначенияСвойств(Строка, Стр);
					Строка.Реквизит = СтрЗаменить(Строка.Реквизит,"Справочник.","Справочники.");
					Строка.Реквизит = СтрЗаменить(Строка.Реквизит,"Документ.","Документы.");
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	Исключение
		Сообщить(ИнформацияОбОшибке().Описание + " " + ИнформацияОбОшибке().Причина);
	КонецПопытки;
	
КонецПроцедуры

Функция ДобавитьОписаниеТипа(ИмяРеквизита, ТипРеквизита)
	
	ОбъектТипа = Метаданные.НайтиПоТипу(ТипРеквизита);
	ИмяТаблицы = ОбъектТипа.ПолноеИмя();
	ОписаниеТипа = """" + ИмяТаблицы + """ КАК Реквизит";	
	Возврат ОписаниеТипа;
	
КонецФункции

Функция ДобавитьУсловия(ИмяРеквизита, ТипРеквизита)
	
	мдОбъекта = Метаданные.НайтиПоТипу(ТипРеквизита);
	ИмяТаблицы = мдОбъекта.ПолноеИмя();
	ПроверкаНаПустыеЗначения = " Об." + ИмяРеквизита + " ССЫЛКА " + ИмяТаблицы;
	ПроверкаНаПустыеЗначения = ПроверкаНаПустыеЗначения + " И ВЫРАЗИТЬ(Об." + ИмяРеквизита + " КАК " + ИмяТаблицы + ").Ссылка есть null";
	Если Не Метаданные.Перечисления.Содержит(мдОбъекта) Тогда
		ПроверкаНаПустыеЗначения = ПроверкаНаПустыеЗначения + " И Об." + ИмяРеквизита + " <> Значение(" + ИмяТаблицы + ".ПустаяСсылка)";
	КонецЕсли;
	
	
	Возврат ПроверкаНаПустыеЗначения;
	
КонецФункции

Функция ВыгрузитьНоменклатураУТ11(Параметры)
    УстановитьПривилегированныйРежим(Истина);
	Результат = Новый Структура("ЕстьОшибки, СообщениеОбОшибке", Ложь, "");
	СтруктураДанных = Параметры.Получить();
	Если СтруктураДанных.ЭтоГруппа тогда //ГРУППА
		ГруппаСсылка = Справочники.Товары.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураДанных.УИД));
		//если новый то создадим
		СтрокаСсылка = Строка(ГруппаСсылка);
		Если Найти(СтрокаСсылка,"Объект не найден") > 0 ИЛИ Найти(СтрокаСсылка,"Object not found") > 0 тогда
			Группа = Справочники.Товары.СоздатьГруппу();
	        Группа.УстановитьСсылкуНового(ГруппаСсылка);
		Иначе
			Группа = ГруппаСсылка.ПолучитьОбъект();
		КонецЕсли;
		Если ЗначениеЗаполнено(СтруктураДанных.УИДРодитель) тогда
			РодительСсылка = Справочники.Товары.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураДанных.УИДРодитель));
			Группа.Родитель = РодительСсылка;
		КонецЕсли;
		Группа.Наименование = СтруктураДанных.Наименование;
		Группа.КраткоеФункциональноеНаименование = СтруктураДанных.Код;
		Группа.ПометкаУдаления = СтруктураДанных.ПометкаУдаления;
		попытка
			Группа.Записать();
		Исключение
			Результат.ЕстьОшибки = Истина;
			Результат.СообщениеОбОшибке = ОписаниеОшибки();
		КонецПопытки;
	Иначе //ЭЛЕМЕНТ 
		ТоварСсылка = Справочники.Товары.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураДанных.УИД));
		//если новый то создадим
		СтрокаСсылка = Строка(ТоварСсылка);
		Если Найти(СтрокаСсылка,"Объект не найден") > 0 ИЛИ Найти(СтрокаСсылка,"Object not found") > 0 тогда
			//еще поищем по Коду-артиклу
			ТоварСсылкаКод = Справочники.Товары.НайтиПоКоду(СтруктураДанных.Артикул);
			Если ЗначениеЗаполнено(ТоварСсылкаКод) тогда
				Товар = ТоварСсылкаКод.ПолучитьОбъект();
			иначе //не нашли по УИД и коду, тогда создаем
				
				//если это Непроизводимый, то не будем создавать и на этом закончим
				Если СтруктураДанных.Статус = "Непроизводимый" тогда
					Возврат Новый ХранилищеЗначения(Результат, Новый СжатиеДанных(9));
				КонецЕсли;
				
				Товар = Справочники.Товары.СоздатьЭлемент();
				Товар.УстановитьСсылкуНового(ТоварСсылка);
			КонецЕсли;
		Иначе
			Товар = ТоварСсылка.ПолучитьОбъект();
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтруктураДанных.УИДРодитель) тогда
			РодительСсылка = Справочники.Товары.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураДанных.УИДРодитель));
			Товар.Родитель = РодительСсылка;
		КонецЕсли;
		
		Товар.Наименование = СтруктураДанных.Наименование;
		Товар.Код = СтруктураДанных.Артикул;//должно быть число!
		Товар.СторонняяПоверка = СтруктураДанных.СторонняяПоверка;
		Товар.ЕАС = СтруктураДанных.ЕАС;
		Товар.СИ = СтруктураДанных.СИ;
		Товар.ПолнНаименование = СтруктураДанных.НаименованиеДляПечати;
		Товар.EAN = СтруктураДанных.EAN; //число
		Товар.Стандартный =  СтруктураДанных.Стандартный;
		Товар.КрупностьЗаказа =  СтруктураДанных.Крупность;
		Товар.КратностьЗапуска =  СтруктураДанных.КратностьЗапуска;
		Товар.КратностьПродажи =  СтруктураДанных.КратностьПродажи;
		Товар.Канбан =  СтруктураДанных.Канбан;
		Товар.СрокПоставки = СтруктураДанных.СрокПоставки;
		Статус = СтруктураДанных.Статус;
		Если Статус = "Производимый" тогда
			Товар.Статус = Перечисления.СтатусыТоваров.Производимый;
		ИначеЕсли Статус = "Непроизводимый" тогда
			Товар.Статус = Перечисления.СтатусыТоваров.НеПроизводимый;
		ИначеЕсли Статус = "Проектный" тогда
			Товар.Статус = Перечисления.СтатусыТоваров.Проектный;
		ИначеЕсли Статус = "Опытный" тогда
			Товар.Статус = Перечисления.СтатусыТоваров.Опытный;
		ИначеЕсли Статус = "Снимаемый с производства" тогда
			Товар.Статус = Перечисления.СтатусыТоваров.СнимаемыйСПроизводства;
		КонецЕсли;
		Товар.ПометкаУдаления = СтруктураДанных.ПометкаУдаления;
		попытка
			Товар.Записать();
		Исключение
			Результат.ЕстьОшибки = Истина;
			Результат.СообщениеОбОшибке = ОписаниеОшибки();
		КонецПопытки;
	КонецЕсли;	
    УстановитьПривилегированныйРежим(Ложь);
	Возврат Новый ХранилищеЗначения(Результат, Новый СжатиеДанных(9)); 	
КонецФункции





