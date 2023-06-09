﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Период.Вариант = ВариантСтандартногоПериода.ЭтаНеделя;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДокументыДляОбменаВебСервис.СписокДокументов КАК СписокДокументов
		|ИЗ
		|	РегистрСведений.ДокументыДляОбменаВебСервис КАК ДокументыДляОбменаВебСервис";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() тогда
		// Вставить обработку выборки ВыборкаДетальныеЗаписи  
		ТЗ = Выборка.СписокДокументов.Получить();
		НужныеСтроки = ТЗ.НайтиСтроки(Новый Структура("Обмен",Истина));
	КонецЕсли;

	Для каждого СтрокаН Из НужныеСтроки цикл
			НоваяСтрока = ТаблицаДоков.Добавить();
			НоваяСтрока.Синоним = СтрокаН.Документ;
			НоваяСтрока.Имя = СтрокаН.Имя;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура Выравнить(Команда)
	Если ЗначениеЗаполнено(Период) тогда
		Результат = ВыравнитьНаСервере();
		Если Не ПустаяСтрока(Результат) тогда
			Предупреждение(Результат);
		КонецЕсли;	
	иначе 
		ПоказатьПредупреждение(,"Заполните период!");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ВыравнитьНаСервере()
	// Вставить содержимое обработчика.
	ВыбранныеСтроки = ТаблицаДоков.НайтиСтроки(Новый Структура("Выравнивать",Истина));
	ТекстЗапроса = "";
	КоличествоСтрок = ВыбранныеСтроки.Количество();
	Порядок = 1;
	Для Каждого СтрокаВ Из ВыбранныеСтроки Цикл
		 ТекстЗапроса = ТекстЗапроса + "Выбрать """ + СтрокаВ.Имя + """ КАК ВидДокумента, Док.Ссылка КАК Ссылка_Ключ,Док.Номер,Док.Дата из Документ." + СтрокаВ.Имя + " КАК Док где Док.Дата Между &Дата1 И &Дата2";
		 Если НЕ Порядок = КоличествоСтрок тогда 
			  ТекстЗапроса = ТекстЗапроса + " ОБЪЕДИНИТЬ ВСЕ "
		  КонецЕсли;
		  Порядок = Порядок + 1;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Дата1",Период.ДатаНачала);
	Запрос.УстановитьПараметр("Дата2",Период.ДатаОкончания);
	РезультатЗапроса = Запрос.Выполнить();
	тзЭтойБазы = РезультатЗапроса.Выгрузить();
	
	ДанныеОтправки = Новый Структура;
	ДанныеОтправки.Вставить("ТекстЗапроса", ТекстЗапроса);
	ПараметрыЗапроса = Новый ТаблицаЗначений;
	ПараметрыЗапроса.Колонки.Добавить("ИмяПараметра", Новый ОписаниеТипов("Строка",,,,Новый КвалификаторыСтроки(25)));
	ПараметрыЗапроса.Колонки.Добавить("ЗначениеПараметра", Новый ОписаниеТипов("Дата")); 
	СтрокаПЗ = ПараметрыЗапроса.Добавить();
	СтрокаПЗ.ИмяПараметра = "Дата1";
	СтрокаПЗ.ЗначениеПараметра = Период.ДатаНачала;
	СтрокаПЗ = ПараметрыЗапроса.Добавить();
	СтрокаПЗ.ИмяПараметра = "Дата2";
	СтрокаПЗ.ЗначениеПараметра = Период.ДатаОкончания;
	ДанныеОтправки.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);
	Результат = СРМ_ОбменВебСервис.СверкаБаз(ДанныеОтправки);
	Если ТипЗнч(Результат) = Тип("Строка") тогда
		Возврат Результат;	
	иначе	
		тзДругойБазы = Результат.Объекты;
	КонецЕсли;
	Колонки = ПолучитьМассивыКолонок(тзЭтойБазы);
	ПолучитьРазличияТаблицЗначений(тзЭтойБазы, тзДругойБазы, Колонки);
	
	Возврат "";
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьМассивыКолонок(тзЭтойБазы)
	
	ПримитивныеТипы = МассивПримитивныхТипов();
	
	Колонки = Новый Структура;
	Колонки.Вставить("Все", Новый Массив);
	Колонки.Вставить("Ключевые", Новый Массив);
	Колонки.Вставить("КлючевыеДляЗаголовков", Новый Массив);	
	Колонки.Вставить("СтруктураПоиска", Новый Массив);
	Колонки.Вставить("Остальные", Новый Массив);
	Колонки.Вставить("Ссылочные", Новый Массив);
	Колонки.Вставить("Перечисления", Новый Массив);
	
	МенеджерыПеречислений = Новый Соответствие;
	
	Для Каждого КолонкаТЗ Из тзЭтойБазы.Колонки Цикл
		ЕстьСсылки = Ложь;
		ЭтоПеречисление = Ложь;
		ТипыКолонки = КолонкаТЗ.ТипЗначения.Типы();
		Для Каждого ТекТип Из ТипыКолонки Цикл
			Если ПримитивныеТипы.Найти(ТекТип) = Неопределено Тогда
				ПолноеИмяМетаданных = Метаданные.НайтиПоТипу(ТекТип).ПолноеИмя();
				Если Лев(НРег(ПолноеИмяМетаданных), 13) = "перечисление." Тогда
					ЭтоПеречисление = Истина;
					МенеджерыПеречислений.Вставить(Метаданные.НайтиПоПолномуИмени(ПолноеИмяМетаданных));
				КонецЕсли;
				
				ЕстьСсылки = Истина;
				Прервать;
				
			КонецЕсли;
		КонецЦикла;
		Если ЕстьСсылки Тогда
			Колонки.Ссылочные.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
		Если ЭтоПеречисление Тогда
			Колонки.Перечисления.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
		
		Если Прав(КолонкаТЗ.Имя, 5) = "_Ключ" Тогда
			Колонки.Ключевые.Добавить(КолонкаТЗ.Имя);
			Колонки.КлючевыеДляЗаголовков.Добавить(СтрЗаменить(КолонкаТЗ.Имя, "_Ключ", ""));
			Колонки.СтруктураПоиска.Добавить(КолонкаТЗ.Имя);
		Иначе
			Колонки.Остальные.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
	КонецЦикла;
	
	Колонки.Вставить("СоотвПеречислений", Новый Соответствие);
	Для Каждого КЗ Из МенеджерыПеречислений Цикл
		МенеджерПеречисления = КЗ.Ключ;
		Для Каждого ЗначениеПеречисления Из МенеджерПеречисления.ЗначенияПеречисления Цикл
			Колонки.СоотвПеречислений.Вставить(Перечисления[МенеджерПеречисления.Имя][ЗначениеПеречисления.Имя], ЗначениеПеречисления.Имя);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Колонки;
	
КонецФункции

&НаСервереБезКонтекста
Функция МассивПримитивныхТипов()
	
	ПримитивныеТипы = Новый Массив;
	ПримитивныеТипы.Добавить(Тип("Null"));
	ПримитивныеТипы.Добавить(Тип("Строка"));
	ПримитивныеТипы.Добавить(Тип("Число"));
	ПримитивныеТипы.Добавить(Тип("Дата"));
	ПримитивныеТипы.Добавить(Тип("Булево"));
	
	Возврат ПримитивныеТипы;
	
КонецФункции

&НаСервере
Процедура ПолучитьРазличияТаблицЗначений(тзЭтойБазы, тзДругойБазы, Колонки)
	ТаблицаНеДостаетВДругойБазе.Очистить();
	ТаблицаНедостаетВЭтойБазе.Очистить();
	
	тзЭтойБазы.Колонки.Добавить("СтрокаУчтена");
	тзЭтойБазы.ЗаполнитьЗначения(Ложь, "СтрокаУчтена");
	
	тзДругойБазы.Колонки.Добавить("СтрокаУчтена");
	тзДругойБазы.ЗаполнитьЗначения(Ложь, "СтрокаУчтена");
	
	СтрокаКолонкиДляПоиска = СтрСоединить(Колонки.СтруктураПоиска, ",");
	тзЭтойБазы.Индексы.Добавить(СтрокаКолонкиДляПоиска+",СтрокаУчтена");
	тзДругойБазы.Индексы.Добавить(СтрокаКолонкиДляПоиска+",СтрокаУчтена");
	
	Для Каждого ЭтаБазаСтрока Из тзЭтойБазы Цикл
		СтруктураПоиска = Новый Структура(СтрокаКолонкиДляПоиска);
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ЭтаБазаСтрока);
		СтруктураПоиска.Вставить("СтрокаУчтена", Ложь);
		
		МассивНайдСтрок = тзДругойБазы.НайтиСтроки(СтруктураПоиска);
		Если МассивНайдСтрок.Количество() = 0 Тогда
			СтрокаДБ = ТаблицаНеДостаетВДругойБазе.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаДБ,ЭтаБазаСтрока);
			СтрокаДБ.Ссылка = ЭтаБазаСтрока.Ссылка_Ключ;
			СтрокаДБ.Выбор = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ДругаяБазаСтрока Из тзДругойБазы Цикл
		Если ДругаяБазаСтрока.СтрокаУчтена Тогда
			Продолжить;
		КонецЕсли;
		СтруктураПоиска = Новый Структура(СтрокаКолонкиДляПоиска);
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ДругаяБазаСтрока);
		СтруктураПоиска.Вставить("СтрокаУчтена", Ложь);
		
		МассивНайдСтрок = тзЭтойБазы.НайтиСтроки(СтруктураПоиска);
		Если МассивНайдСтрок.Количество() = 0 Тогда
			СтрокаЭБ = ТаблицаНедостаетВЭтойБазе.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаЭБ,ДругаяБазаСтрока);
			СтрокаЭБ.Ссылка = ДругаяБазаСтрока.Ссылка_Ключ;
			СтрокаЭБ.Выбор = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗарегатьВЭтойБазе(Команда)
	ЗарегатьВЭтойБазеНаСервере();
	ПоказатьПредупреждение(,"Регистрация выполнена!");
КонецПроцедуры

&НаСервере
Процедура ЗарегатьВЭтойБазеНаСервере()
	МассивПолучателей = СРМ_ОбменВебСервис.ПолучитьМассивУзловПолучателей("ПланОбменаЛинейкаГлавная"); 
	СтрокиДляРегистрации = ТаблицаНеДостаетВДругойБазе.НайтиСтроки(Новый Структура("Выбор",Истина));
	ТЗДляРегистрации = ТаблицаНеДостаетВДругойБазе.Выгрузить(СтрокиДляРегистрации,"Ссылка,ВидДокумента");
	//так не работает на ОВНЕ
	//МассивДляРегистрации = ТЗДляРегистрации.ВыгрузитьКолонку("Ссылка");
	//Если МассивДляРегистрации.Количество() > 0 тогда
	//	ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, МассивДляРегистрации);
	//КонецЕсли;
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
		// Вставить обработку выборки ВыборкаДетальныеЗаписи 
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
	
	//Для Каждого Ссылка Из МассивДляРегистрации Цикл 
	//	Если Ссылка.Проведен тогда
	//		//ОЧЕНЬ МЕДЛЕННО
	//		Об = Ссылка.ПолучитьОбъект();
	//		Для Каждого Набор Из Об.Движения Цикл
	//			ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, Набор);
	//		КонецЦикла;
	//		
	//		//ТАК ЖЕ МЕДЛЕННО
	//		//Движения = Ссылка.Метаданные().Движения;
	//		//Для каждого СтрокаДвижения Из Движения цикл 
	//		//	Набор = РегистрыНакопления[СтрокаДвижения.Имя].СоздатьНаборЗаписей();
	//		//	Набор.Отбор.Регистратор.ВидСравнения = ВидСравнения.Равно;
	//		//	Набор.Отбор.Регистратор.Значение = Ссылка;
	//		//	Набор.Отбор.Регистратор.Использование = Истина;
	//		//	ПланыОбмена.ЗарегистрироватьИзменения(МассивПолучателей, Набор);
	//		//КонецЦикла;
	//	КонецЕсли;
	//КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура ЗарегатьВДругойБазе(Команда)
	Результат = ЗарегатьВДругойБазеНаСервере();
	ПоказатьПредупреждение(,Результат);
КонецПроцедуры


&НаСервере
Функция  ЗарегатьВДругойБазеНаСервере()
	СтрокиДляРегистрации = ТаблицаНеДостаетВЭтойБазе.НайтиСтроки(Новый Структура("Выбор",Истина));
	ТЗДляРегистрации = ТаблицаНеДостаетВЭтойБазе.Выгрузить(СтрокиДляРегистрации,"Ссылка,ВидДокумента");
	//МассивДляРегистрации = ТЗДляРегистрации.ВыгрузитьКолонку("Ссылка"); 
	Результат = "Нечего регистрировать";
	Если ТЗДляРегистрации.Количество() > 0 тогда
		ДанныеОтправки = Новый Структура;
		ДанныеОтправки.Вставить("Регистрация", Истина); 
		ДанныеОтправки.Вставить("ТЗДляРегистрации", ТЗДляРегистрации);
		Результат = СРМ_ОбменВебСервис.СверкаБаз(ДанныеОтправки);
	КонецЕсли;
	Возврат Результат;
КонецФункции


&НаКлиенте
Процедура УстановитьИскать(Команда)
	Для Каждого СтрокаТД Из ТаблицаДоков цикл
		 СтрокаТД.Выравнивать = Истина;
	КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура СнятьИскать(Команда)
	Для Каждого СтрокаТД Из ТаблицаДоков цикл
		 СтрокаТД.Выравнивать = Ложь;
	КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура УстановитьВыбор(Команда)
	Для Каждого СтрокаТД Из ТаблицаНеДостаетВДругойБазе цикл
		 СтрокаТД.Выбор = Истина;
	КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура СнятьВыбор(Команда)
	Для Каждого СтрокаТД Из ТаблицаНеДостаетВДругойБазе цикл
		 СтрокаТД.Выбор = Ложь;
	КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура УстановитьВыбор2(Команда)
	Для Каждого СтрокаТД Из ТаблицаНеДостаетВЭтойБазе цикл
		 СтрокаТД.Выбор = Истина;
	КонецЦикла;	
КонецПроцедуры


&НаКлиенте
Процедура СнятьВыбор2(Команда)
	Для Каждого СтрокаТД Из ТаблицаНеДостаетВЭтойБазе цикл
		 СтрокаТД.Выбор = Ложь;
	КонецЦикла;	
КонецПроцедуры

