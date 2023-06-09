﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
ОбновитьДополнительныеКолонки();
Статус = РегистрыСведений.СтатусыНакладныхНаСборку.ПолучитьПоследнее(ТекущаяДата(),Новый Структура("НакладнаяНаСборку",Объект.Ссылка)).Статус;
	Если (Строка(Статус) = "Собран")или
		 (Строка(Статус) = "На упаковке")или
		 (Строка(Статус) = "Упакован")Тогда
	ЭтаФорма.ТолькоПросмотр = Не РольДоступна("Администратор");
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПечатьНакладнойНаСборкуНаСервере()
ТабДок = Новый ТабличныйДокумент;
ТаблицаННС = Новый ТаблицаЗначений;

ТаблицаННС.Колонки.Добавить("Товар");
ТаблицаННС.Колонки.Добавить("Продукция");
ТаблицаННС.Колонки.Добавить("ГруппаЛинеек");
ТаблицаННС.Колонки.Добавить("Порядок");
ТаблицаННС.Колонки.Добавить("Количество");

ОбъектЗн = РеквизитФормыВЗначение("Объект");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблТовар = Макет.ПолучитьОбласть("Товар");
ОблКонец = Макет.ПолучитьОбласть("Конец");

	Для каждого ТЧ Из Объект.ТабличнаяЧасть Цикл	
	ТЧ_ННС = ТаблицаННС.Добавить();
	ТЧ_ННС.Товар = ТЧ.Товар;
	ТЧ_ННС.Продукция = ТЧ.Продукция;	
	ТЧ_ННС.ГруппаЛинеек = ТЧ.Продукция.Линейка.Родитель;
	ТЧ_ННС.Порядок = ТЧ.Продукция.Линейка.Родитель.Порядок;
	ТЧ_ННС.Количество = ТЧ.Количество;
	КонецЦикла;
ТаблицаННС.Свернуть("Порядок,ГруппаЛинеек,Товар,Продукция","Количество");
ТаблицаННС.Сортировать("Порядок,ГруппаЛинеек,Товар,Продукция");
КоличествоВсего = 0;
ОблШапка.Параметры.Контрагент = Объект.Контрагент;
ОблШапка.Параметры.ТранспортнаяКомпания = Объект.КартаДоставки.ТрансКом;
ОблШапка.Параметры.Город = Объект.КартаДоставки.Город;
ОблШапка.Параметры.Номер = Объект.Номер;
ОблШапка.Параметры.ДатаОтгрузки = Формат(Объект.ДатаОтгрузки,"ДЛФ=DD")+" ("+Формат(Объект.ДатаОтгрузки,"ДФ=дддд")+")";
ОблШапка.Параметры.НомерЛинейкиУпаковки = Объект.ЛинейкаУпаковки;
СписокСчетов = Новый СписокЗначений;

	Для каждого ТЧ Из Объект.ТабличнаяЧасть Цикл
	Выборка = СписокСчетов.НайтиПоЗначению(СокрЛП(ТЧ.ЗаказНаПроизводство.Номер));
		Если Выборка = Неопределено Тогда
		СписокСчетов.Добавить(СокрЛП(ТЧ.ЗаказНаПроизводство.Номер));		
		КонецЕсли; 
	КонецЦикла;
ОблШапка.Параметры.НомераСчетов = СписокСчетов; 
ТабДок.Вывести(ОблШапка);
QRCode = СокрЛП(Объект.Номер)+";"+ЗначениеВСтрокуВнутр(Объект.Ссылка);
	Для каждого ТЧ Из ТаблицаННС Цикл
		Если ТипЗнч(ТЧ.Продукция) = Тип("СправочникСсылка.Материалы") Тогда
        ОблТовар.Параметры.Линейка = "ТНП";
		Иначе
		ОблТовар.Параметры.Линейка = ТЧ.ГруппаЛинеек;
		КонецЕсли; 		
	ОблТовар.Параметры.Товар = ТЧ.Товар;
	ОблТовар.Параметры.Артикул = ТЧ.Товар.Код;
	ОблТовар.Параметры.Количество = ТЧ.Количество;
	ОблТовар.Параметры.КратностьПродажи = ТЧ.Товар.КратностьПродажи;
	ОблТовар.Параметры.ЕдиницаИзмерения = СокрЛП(ТЧ.Продукция.ЕдиницаИзмерения.Наименование);
	ОблТовар.Параметры.Стеллаж = "";
	ОблТовар.Параметры.Стойка = "";
	ОблТовар.Параметры.Полка = "";
	ОблТовар.Параметры.Ячейка = "";
	ЯчейкиХранения = РегистрыСведений.ЯчейкиХранения.Выбрать(Новый Структура("МПЗ",ТЧ.Продукция));
		Пока ЯчейкиХранения.Следующий() Цикл
		ОблТовар.Параметры.Стеллаж = ЯчейкиХранения.Стеллаж;
		ОблТовар.Параметры.Стойка = ЯчейкиХранения.Стойка;
		ОблТовар.Параметры.Полка = ЯчейкиХранения.Полка;
		ОблТовар.Параметры.Ячейка = ЯчейкиХранения.Ячейка;		
		КонецЦикла;	
	ТабДок.Вывести(ОблТовар);
	QRCode = QRCode+";"+Формат(ТЧ.Товар.Код,"ЧЦ=6; ЧГ=0")+";"+ТЧ.Количество;
	КоличествоВсего = КоличествоВсего + ТЧ.Количество;
	КонецЦикла;
ДанныеQRКода = УправлениеПечатью.ДанныеQRКода(QRCode, 0, 500);	
	Если ТипЗнч(ДанныеQRКода) = Тип("ДвоичныеДанные") Тогда
	КартинкаQRКода = Новый Картинка(ДанныеQRКода);
	ОблКонец.Рисунки.QRCode.Картинка = КартинкаQRКода;
	Иначе
	Сообщить("Не удалось сформировать QR-код!");
	КонецЕсли;
ОблКонец.Параметры.Количество = КоличествоВсего;
ОблКонец.Параметры.Комментарий = Объект.Комментарий;
ТабДок.Вывести(ОблКонец);
ТабДок.ПолеСлева =0;
ТабДок.ПолеСверху = 0;
ТабДок.ПолеСнизу = 0;
ТабДок.ПолеСправа = 0;
ТабДок.РазмерКолонтитулаСверху = 0;
ТабДок.РазмерКолонтитулаСнизу = 0;
Возврат(ТабДок);
КонецФункции 

&НаКлиенте
Процедура ПечатьНакладнойНаСборку(Команда)
ТД = ПечатьНакладнойНаСборкуНаСервере();
ТД.Показать("Накладные на сборку");
КонецПроцедуры

&НаСервере
Функция ОбновитьДополнительныеКолонки()
	Для каждого ТЧ Из Объект.ТабличнаяЧасть Цикл
		Если ТипЗнч(ТЧ.Продукция) = Тип("СправочникСсылка.Номенклатура") Тогда
		ТЧ.Линейка = ТЧ.Продукция.Линейка;
		ИначеЕсли ТипЗнч(ТЧ.Продукция) = Тип("СправочникСсылка.Материалы") Тогда
		ТЧ.Линейка = "ТНП";
		КонецЕсли;
	КонецЦикла;                          
КонецФункции

&НаСервере
Функция ПолучитьСписокПродукции(Товар)
СписокПродукции = Новый СписокЗначений;
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка
	|ИЗ
	|	РегистрСведений.СтатусыМПЗ.СрезПоследних(&НаДату, ) КАК СтатусыМПЗСрезПоследних
	|		ПОЛНОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
	|		ПО СтатусыМПЗСрезПоследних.МПЗ = Номенклатура.Ссылка
	|ГДЕ
	|	Номенклатура.Товар = &Товар
	|	И СтатусыМПЗСрезПоследних.Статус <> &Статус";
Запрос.УстановитьПараметр("Товар",Товар);
Запрос.УстановитьПараметр("Статус",Перечисления.СтатусыСпецификаций.Запрещённая);
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
РезультатЗапроса = Запрос.Выполнить();
Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
	СписокПродукции.Добавить(Выборка.Ссылка,СокрЛП(Выборка.Ссылка.Наименование));
	КонецЦикла;
Запрос.Текст = 
	"ВЫБРАТЬ
	|	Материалы.Ссылка КАК Ссылка
	|ИЗ
	|	РегистрСведений.СтатусыМПЗ.СрезПоследних(&НаДату, ) КАК СтатусыМПЗСрезПоследних
	|		ПОЛНОЕ СОЕДИНЕНИЕ Справочник.Материалы КАК Материалы
	|		ПО СтатусыМПЗСрезПоследних.МПЗ = Материалы.Ссылка
	|ГДЕ
	|	Материалы.Товар = &Товар
	|	И СтатусыМПЗСрезПоследних.Статус <> &Статус";
Запрос.УстановитьПараметр("Товар",Товар);
Запрос.УстановитьПараметр("Статус",Перечисления.СтатусыМПЗ.Запрещённая);
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
РезультатЗапроса = Запрос.Выполнить();
Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
	СписокПродукции.Добавить(Выборка.Ссылка,СокрЛП(Выборка.Ссылка.Наименование));
	КонецЦикла;
Возврат(СписокПродукции);
КонецФункции 

&НаКлиенте
Процедура ТабличнаяЧастьПродукцияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
СтандартнаяОбработка = Ложь;
	Если ЗначениеЗаполнено(Элементы.ТабличнаяЧасть.ТекущиеДанные.Товар) Тогда
	СписокПродукции = ПолучитьСписокПродукции(Элементы.ТабличнаяЧасть.ТекущиеДанные.Товар);
		Если СписокПродукции.Количество() > 0 Тогда
		ВыбПродукция = СписокПродукции.ВыбратьЭлемент("Выберите продукцию");
			Если ВыбПродукция <> Неопределено Тогда
			Элементы.ТабличнаяЧасть.ТекущиеДанные.Продукция = ВыбПродукция.Значение;
			ОбновитьДополнительныеКолонки();
			КонецЕсли;
		Иначе
		Сообщить("Товар не привязан ни к одной спецификации или материалу!");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ТабличнаяЧастьПослеУдаленияНаСервере()
СписокУдаляемых = Новый СписокЗначений;

	Для каждого ТЧ Из Объект.ЗоныКомплектации Цикл
	ЗК = ТЧ.ЗонаКомплектации;
	флНайден = Ложь;
		Для каждого ТЧ_П Из Объект.ТабличнаяЧасть Цикл	
			Если ТипЗнч(ТЧ_П.Продукция) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если ТЧ_П.Продукция.Линейка.ЗонаКомплектации = ЗК Тогда
				флНайден = Истина;
				Прервать;
				КонецЕсли;
			Иначе
				Если ЗК = Перечисления.ЗоныКомплектации.ТНП Тогда
				флНайден = Истина;
				Прервать;			
				КонецЕсли; 		
			КонецЕсли;
		КонецЦикла;
			Если Не	флНайден Тогда
			СписокУдаляемых.Добавить(ТЧ);
			КонецЕсли; 
	КонецЦикла; 
		Для каждого Стр Из СписокУдаляемых Цикл
		Сообщить("Отмените ННС для зоны комплектации "+Стр.Значение.ЗонаКомплектации);
		Объект.ЗоныКомплектации.Удалить(Стр.Значение);
		КонецЦикла;  
КонецПроцедуры

&НаКлиенте
Процедура ТабличнаяЧастьПослеУдаления(Элемент)
ТабличнаяЧастьПослеУдаленияНаСервере();
КонецПроцедуры
