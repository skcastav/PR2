﻿
&НаСервере
Процедура ЗагрузитьНаСервере(СерийныйНомерEnLogic,ПроверочныйКод)
Выбор = Справочники.СерийныеНомераEnLogic.НайтиПоКоду(СерийныйНомерEnLogic+ПроверочныйКод);
	Если Выбор.Пустая() Тогда
	Запрос = Новый Запрос;

	Запрос.Текст = 
		"ВЫБРАТЬ
		|	БарКоды.БарКод
		|ИЗ
		|	РегистрСведений.БарКоды КАК БарКоды
		|ГДЕ
		|	БарКоды.СерийныйНомерEnLogic = &СерийныйНомерEnLogic";
	Запрос.УстановитьПараметр("СерийныйНомерEnLogic", СерийныйНомерEnLogic+ПроверочныйКод);
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		Если ВыборкаДетальныеЗаписи.Количество() = 0 Тогда
		Спр = Справочники.СерийныеНомераEnLogic.СоздатьЭлемент();
		Спр.Код = СерийныйНомерEnLogic+ПроверочныйКод; 
		Спр.Записать();	
		Иначе
	    Сообщить(СерийныйНомерEnLogic+"/"+ПроверочныйКод+" уже присвоен изделию!");
		КонецЕсли; 
	Иначе
	Сообщить(СерийныйНомерEnLogic+"/"+ПроверочныйКод+" уже загружен в базу!");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Загрузить(Команда)
Текст = Новый ТекстовыйДокумент;
Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);

Диалог.Заголовок = "Выберите файл с серийными номерами EnLogic";
Диалог.ПолноеИмяФайла = ""; 
Фильтр = "s/n EnLogic (*.csv)|*.csv"; 
Диалог.Фильтр = Фильтр; 
Диалог.МножественныйВыбор = Ложь;
	Если Диалог.Выбрать() Тогда
	Текст.Прочитать(Диалог.ПолноеИмяФайла);
		Для НомерСтроки = 2 По Текст.КоличествоСтрок() Цикл 
	    Стр = Текст.ПолучитьСтроку(НомерСтроки); 
	    Стр = Сред(Стр, Найти(Стр,";")+1); 
	    СерийныйНомерEnLogic = Лев(Стр,Найти(Стр,";")-1);
		СерийныйНомерEnLogic = СтрЗаменить(СерийныйНомерEnLogic,"-",""); 
		ПроверочныйКод = Сред(Стр, Найти(Стр,";")+1);
		ЗагрузитьНаСервере(СерийныйНомерEnLogic,ПроверочныйКод);
		КонецЦикла;
	Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры
