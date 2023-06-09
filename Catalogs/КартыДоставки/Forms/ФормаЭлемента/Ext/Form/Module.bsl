﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Объект.Ссылка.Пустая() Тогда
	Объект.ДатаСоздания = ТекущаяДата();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПечатьНаСервере()
ТабДок = Новый ТабличныйДокумент;

ОбъектЗн = РеквизитФормыВЗначение("Объект");
Макет = ОбъектЗн.ПолучитьМакет("КартаДоставки");

ОблШапка = Макет.ПолучитьОбласть("Шапка");

ОблШапка.Параметры.ПочтоваяОрганизация = Объект.ТрансКом;
ОблШапка.Параметры.Контрагент = Объект.НазваниеКлиента;
ОблШапка.Параметры.Город = Объект.Город;
ОблШапка.Параметры.Телефон = Объект.Телефон;
ОблШапка.Параметры.Организация = Объект.Организация;
ОблШапка.Параметры.КодОплаты = Объект.КодОплаты;
ТабДок.Вывести(ОблШапка);
Возврат(ТабДок);
КонецФункции

&НаКлиенте
Процедура Печать(Команда)
ТД = ПечатьНаСервере();
ТД.Показать("Карта доставки");
КонецПроцедуры
