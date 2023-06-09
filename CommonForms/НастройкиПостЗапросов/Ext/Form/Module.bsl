﻿
&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	//Вставить содержимое обработчика
	НастройкиПостЗапросов = Новый Структура("Токен,КонтрольСвязи,ВыгрузкаПослеСбоя,Ошибка,Сервер", СокрЛП(Токен),СокрЛП(КонтрольСвязи),СокрЛП(ВыгрузкаПослеСбоя),СокрЛП(Ошибка),СокрЛП(Сервер));
	Константы.НастройкиПостЗапросов.Установить(Новый ХранилищеЗначения(НастройкиПостЗапросов));
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//Вставить содержимое обработчика
	НастройкиПостЗапросов = Константы.НастройкиПостЗапросов.Получить().Получить();
	Если НЕ НастройкиПостЗапросов = Неопределено тогда
		Токен = НастройкиПостЗапросов.Токен;
		КонтрольСвязи = НастройкиПостЗапросов.КонтрольСвязи;
		ВыгрузкаПослеСбоя = НастройкиПостЗапросов.ВыгрузкаПослеСбоя;
		Ошибка = НастройкиПостЗапросов.Ошибка;
		Сервер = НастройкиПостЗапросов.Сервер;
	КонецЕсли;	
КонецПроцедуры
