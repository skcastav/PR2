﻿
&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Если Найти(Объект.Наименование," ") > 0 Тогда	
	Отказ = Истина;
	Сообщить("Наименование параметра не должно содержать пробелов!");
	КонецЕсли;
КонецПроцедуры
