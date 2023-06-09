﻿
&НаСервере
Процедура СформироватьНаСервере()
ТабДок.Очистить();

Запрос = Новый Запрос;

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет"); 
ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");	

ОблШапка.Параметры.НаДату = Формат(ТекущаяДата(),"ДФ=dd.MM.yyyy");
ОблШапка.Параметры.СписокЛинеек = СписокЛинеек;
ТабДок.Вывести(ОблШапка);

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОстатки.МПЗ,
	|	МестаХраненияОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.МестаХранения.Остатки(&НаДату, МестоХранения = &МестоХранения) КАК МестаХраненияОстатки";
	Если СписокГруппМПЗ.Количество() > 0 Тогда
	Запрос.Текст = Запрос.Текст + " ГДЕ МестаХраненияОстатки.МПЗ В ИЕРАРХИИ(&СписокГруппМПЗ)";
	Запрос.УстановитьПараметр("СписокГруппМПЗ", СписокГруппМПЗ);	
	КонецЕсли; 
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
Запрос.УстановитьПараметр("МестоХранения", СписокЛинеек[0].Значение.МестоХраненияКанбанов);
РезультатЗапроса = Запрос.Выполнить();
ТаблицаОстатков = РезультатЗапроса.Выгрузить();
ТаблицаОстатков.Сортировать("МПЗ");

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОстатки.МПЗ,
	|	МестаХраненияОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.МестаХранения.Остатки(&НаДату, МестоХранения = &МестоХранения) КАК МестаХраненияОстатки";
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
Запрос.УстановитьПараметр("МестоХранения", СписокЛинеек[0].Значение.Подразделение.МестоХраненияПоУмолчанию);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаМестоХраненияОсновное = РезультатЗапроса.Выбрать();

СписокМТК1.Очистить();
Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.ПЗ.ДокументОснование КАК МТК
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПервых КАК ЭтапыПроизводственныхЗаданийСрезПервых
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.Линейка В(&СписокЛинеек)
	|	И ЭтапыПроизводственныхЗаданийСрезПервых.ПЗ.ДокументОснование.Статус <> 3
	|	И ЭтапыПроизводственныхЗаданийСрезПервых.ДатаНачала = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);
РезультатЗапроса = Запрос.Выполнить();
Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
	СписокМТК1.Добавить(Выборка.МТК);
	КонецЦикла;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПередачиВПроизводствоОстатки.МПЗ,
	|	ПередачиВПроизводствоОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ПередачиВПроизводство.Остатки(&НаДату, ) КАК ПередачиВПроизводствоОстатки
	|ГДЕ
	|	ПередачиВПроизводствоОстатки.Документ.Линейка В(&СписокЛинеек)
	|	И ПередачиВПроизводствоОстатки.Документ В(&СписокМТК)";
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);
Запрос.УстановитьПараметр("СписокМТК", СписокМТК1);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаПроизв1 = РезультатЗапроса.Выбрать();

СписокМТК2.Очистить();
Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.ПЗ.ДокументОснование КАК МТК
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий.СрезПервых КАК ЭтапыПроизводственныхЗаданийСрезПервых
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданийСрезПервых.Линейка В(&СписокЛинеек)
	|	И ЭтапыПроизводственныхЗаданийСрезПервых.ПЗ.ДокументОснование.Статус <> 3
	|	И ЭтапыПроизводственныхЗаданийСрезПервых.ДатаНачала <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);
РезультатЗапроса = Запрос.Выполнить();
Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
	СписокМТК2.Добавить(Выборка.МТК);
	КонецЦикла;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПередачиВПроизводствоОстатки.МПЗ,
	|	ПередачиВПроизводствоОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ПередачиВПроизводство.Остатки(&НаДату, ) КАК ПередачиВПроизводствоОстатки
	|ГДЕ
	|	ПередачиВПроизводствоОстатки.Документ.Линейка В(&СписокЛинеек)
	|	И ПередачиВПроизводствоОстатки.Документ В(&СписокМТК)";
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);
Запрос.УстановитьПараметр("СписокМТК", СписокМТК2);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаПроизв2 = РезультатЗапроса.Выбрать();

	Для каждого ТЧ Из ТаблицаОстатков Цикл
	ОблМПЗ.Параметры.Статус = ПолучитьСтатус(ТЧ.МПЗ);
	ОблМПЗ.Параметры.Наименование = СокрЛП(ТЧ.МПЗ.Наименование);
	ОблМПЗ.Параметры.МПЗ = ТЧ.МПЗ;
	ОблМПЗ.Параметры.КолЛинейка = ТЧ.Количество;
	ВыборкаМестоХраненияОсновное.Сбросить();
		Если ВыборкаМестоХраненияОсновное.НайтиСледующий(Новый Структура("МПЗ",ТЧ.МПЗ)) Тогда
		ОблМПЗ.Параметры.КолОснСклад = ВыборкаМестоХраненияОсновное.Количество;
		Иначе
		ОблМПЗ.Параметры.КолОснСклад = 0;
		КонецЕсли;
	КолПроизвНеЗап = 0;
	ВыборкаПроизв1.Сбросить();
		Пока ВыборкаПроизв1.НайтиСледующий(Новый Структура("МПЗ",ТЧ.МПЗ)) Цикл
		КолПроизвНеЗап = КолПроизвНеЗап + ВыборкаПроизв1.Количество;
		КонецЦикла;
	ОблМПЗ.Параметры.КолПроизвНеЗап = КолПроизвНеЗап;
	ОблМПЗ.Параметры.КолВсего = ОблМПЗ.Параметры.КолЛинейка + КолПроизвНеЗап;
	КолПроизвЗап = 0;
	ВыборкаПроизв2.Сбросить();
		Пока ВыборкаПроизв2.НайтиСледующий(Новый Структура("МПЗ",ТЧ.МПЗ)) Цикл
		КолПроизвЗап = КолПроизвЗап + ВыборкаПроизв2.Количество;
		КонецЦикла;
	ОблМПЗ.Параметры.КолПроизвЗап = КолПроизвЗап;
	ТабДок.Вывести(ОблМПЗ);
	КонецЦикла; 
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 3;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
	СформироватьНаСервере();
	КонецЕсли;  
КонецПроцедуры

