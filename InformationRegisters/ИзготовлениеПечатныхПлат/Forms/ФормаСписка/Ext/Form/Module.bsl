﻿
&НаКлиенте
Процедура СкрытьНеАктуальныеПриИзменении(Элемент)
//Список.Отбор.Элементы.Очистить();
//	Если СкрытьНеАктуальные Тогда
//	ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
//	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Действующий");
//	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
//	ЭлементОтбора.Использование = Истина;
//	ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
//	ЭлементОтбора.ПравоеЗначение = Истина;	
//	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
СкрытьНеАктуальныеПриИзменении(Неопределено);
КонецПроцедуры
