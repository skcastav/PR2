﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не Запись.НормаРасходов.Пустая() Тогда
		Если (ТипЗнч(Запись.Элемент) = Тип("СправочникСсылка.Номенклатура"))или
			 (ТипЗнч(Запись.Элемент) = Тип("СправочникСсылка.Материалы")) Тогда
		Элементы.ЕдиницаИзмерения.Заголовок = Запись.Элемент.ОсновнаяЕдиницаИзмерения;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НормаРасходовПриИзменении(Элемент)
НормаРасходовПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура НормаРасходовПриИзмененииНаСервере()
	Если (ТипЗнч(Запись.Элемент) = Тип("СправочникСсылка.Номенклатура"))или
		 (ТипЗнч(Запись.Элемент) = Тип("СправочникСсылка.Материалы")) Тогда
	Элементы.ЕдиницаИзмерения.Заголовок = Запись.Элемент.ОсновнаяЕдиницаИзмерения;
	КонецЕсли; 		
КонецПроцедуры