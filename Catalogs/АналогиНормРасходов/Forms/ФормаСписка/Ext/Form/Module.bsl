﻿
&НаСервере
Функция ПолучитьВладельцаФормы()
КоллекцияПолейОтбора=ЭтаФорма.Список.Отбор.Элементы;
ТекущийВладелецФормы=Неопределено;
	Для каждого ПолеОтбора Из КоллекцияПолейОтбора Цикл
		Если Строка(ПолеОтбора.ЛевоеЗначение)="Владелец" Тогда
 		ТекущийВладелецФормы=ПолеОтбора.ПравоеЗначение;
 		Прервать;
 		КонецЕсли;
 	КонецЦикла;
Возврат (ТекущийВладелецФормы);
КонецФункции

&НаСервере
Функция ПолучитьЭлементВладельцаФормы()
КоллекцияПолейОтбора=ЭтаФорма.Список.Отбор.Элементы;
ТекущийЭлементВладельцаФормы=Справочники.НормыРасходов.ПустаяСсылка();
	Для каждого ПолеОтбора Из КоллекцияПолейОтбора Цикл
		Если Строка(ПолеОтбора.ЛевоеЗначение)="Владелец" Тогда
 		ТекущийЭлементВладельцаФормы=ПолеОтбора.ПравоеЗначение;
 		Прервать;
 		КонецЕсли;
 	КонецЦикла;
Возврат(ТекущийЭлементВладельцаФормы.Элемент);
КонецФункции

&НаСервере
Процедура ДобавитьАналогНаСервере(ВыбАналог,Представление)
Владелец = ПолучитьВладельцаФормы();
Приоритет = 1;
ТаблицаАналогов = ОбщегоНазначенияПовтИсп.ПолучитьАналогиНормРасходов(Владелец,,Истина);
	Для каждого ТЧ Из ТаблицаАналогов Цикл
		Если ТЧ.Ссылка.Элемент = ВыбАналог Тогда
		Возврат;
		КонецЕсли;
	Приоритет = Макс(Приоритет,ТЧ.Ссылка.Приоритет);	
	КонецЦикла;
НормыНР = РегистрыСведений.НормыРасходов.ПолучитьПоследнее(ТекущаяДата(),Новый Структура("НормаРасходов",Владелец));
НоваяАНР = Справочники.АналогиНормРасходов.СоздатьЭлемент();
НоваяАНР.Владелец = Владелец;
НоваяАНР.Приоритет = Приоритет + 1;
НоваяАНР.Элемент = ВыбАналог;
НоваяАНР.Наименование = Представление;
	Если ТипЗнч(ВыбАналог) = Тип("СправочникСсылка.Материалы") Тогда
	НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Материал;
	ИначеЕсли ТипЗнч(ВыбАналог) = Тип("СправочникСсылка.ТехОперации") Тогда	
	НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.ТехОперация;
	ИначеЕсли ТипЗнч(ВыбАналог) = Тип("СправочникСсылка.ТехОснастка") Тогда	
	НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.ТехОснастка;
	Иначе
		Если Найти(Представление,"Узел") > 0 Тогда
		НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Узел;		
        ИначеЕсли Найти(Представление,"Деталь") > 0 Тогда
        НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Деталь;
        ИначеЕсли Найти(Представление,"Основа") > 0 Тогда
        НоваяАНР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Основа;
		КонецЕсли; 		
	КонецЕсли;
НоваяАНР.Записать();
РАНР = РегистрыСведений.АналогиНормРасходов.СоздатьМенеджерЗаписи();
РАНР.Период = ТекущаяДата();
РАНР.Владелец = НоваяАНР.Владелец;
РАНР.АналогНормыРасходов = НоваяАНР.Ссылка;
РАНР.Норма = НормыНР.Норма;
РАНР.Записать();
КонецПроцедуры

&НаКлиенте
Процедура ВозможныеАналоги(Команда)
СписокАналогов = ОбщийМодульВызовСервера.ПолучитьСписокВозможныхАналогов(ПолучитьЭлементВладельцаФормы());
	Если СписокАналогов.ОтметитьЭлементы("Выберите аналоги для добавления") Тогда
		Для каждого ВыбАналог Из СписокАналогов Цикл
			Если ВыбАналог.Пометка Тогда
			ДобавитьАналогНаСервере(ВыбАналог.Значение,ВыбАналог.Представление);
			КонецЕсли; 
		КонецЦикла; 
	Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УдалитьНаСервере(АНР)
УдаляемыйЭлемент = АНР.ПолучитьОбъект(); 
УдаляемыйЭлемент.Удалить();
КонецПроцедуры 

&НаКлиенте
Процедура УдалитьАналоги(Команда)
	Если Вопрос("Вы действительно хотите удалить аналоги без истории?", РежимДиалогаВопрос.ДаНет, 0) = КодВозвратаДиалога.Нет Тогда
    Возврат;
	КонецЕсли;
		Для каждого ТекСтрока из Элементы.Список.ВыделенныеСтроки Цикл
		УдалитьНаСервере(Элементы.Список.ТекущаяСтрока);
		КонецЦикла;
Элементы.Список.Обновить(); 	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
ЭтаФорма.Заголовок = "Аналоги норм расходов для " +ПолучитьЭлементВладельцаФормы();
Список.Параметры.УстановитьЗначениеПараметра("НаДату",ТекущаяДата());
КонецПроцедуры
