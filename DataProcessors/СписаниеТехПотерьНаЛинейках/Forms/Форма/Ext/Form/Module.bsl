﻿
&НаСервере
Функция РассчитатьНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВыпускПродукцииКанбанСписание.МПЗ КАК МПЗ,
	|	ВыпускПродукцииКанбанСписание.Количество КАК Количество
	|ИЗ
	|	Документ.ВыпускПродукцииКанбан.Списание КАК ВыпускПродукцииКанбанСписание
	|ГДЕ
	|	ВыпускПродукцииКанбанСписание.Ссылка.Дата МЕЖДУ &ДатаНач И &ДатаКон
	|	И ВыпускПродукцииКанбанСписание.Ссылка.ДокументОснование.Линейка В ИЕРАРХИИ(&СписокЛинеек)
	|	И ВыпускПродукцииКанбанСписание.МПЗ В ИЕРАРХИИ(&СписокМПЗ)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВыпускПродукцииКанбанСписание.МПЗ.Наименование
	|ИТОГИ
	|	СУММА(Количество)
	|ПО
	|	МПЗ";
Запрос.УстановитьПараметр("ДатаНач", НачалоДня(Объект.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаКон", КонецДня(Объект.Период.ДатаОкончания));
Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);
Запрос.УстановитьПараметр("СписокМПЗ", СписокГруппМПЗ);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаМПЗ = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
Подразделение = СписокЛинеек[0].Значение.Подразделение;
Списание = Документы.СписаниеМПЗПрочее.СоздатьДокумент();
Списание.Дата = ТекущаяДата();
Списание.УстановитьНовыйНомер(ПрисвоитьПрефикс(Подразделение));
Списание.Автор = ПараметрыСеанса.Пользователь;
Списание.Подразделение = Подразделение;
Списание.МестоХранения = МестоХранения;
Списание.Статья = СтатьяСписания;
Списание.Комментарий = "Технологические потери за период с "+Формат(Объект.Период.ДатаНачала,"ДФ=dd.MM.yyyy")+" по "+Формат(Объект.Период.ДатаОкончания,"ДФ=dd.MM.yyyy");
	Пока ВыборкаМПЗ.Следующий() Цикл
	Кол = Окр(ВыборкаМПЗ.Количество/100*Объект.ПроцентСписания,0,РежимОкругления.Окр15как20);
		Если Кол > 0 Тогда
		ТЧ = Списание.ТабличнаяЧасть.Добавить();
		ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Материалы;
		ТЧ.МПЗ = ВыборкаМПЗ.МПЗ;
		ТЧ.Количество = Кол;
		ТЧ.ЕдиницаИзмерения = ВыборкаМПЗ.МПЗ.ОсновнаяЕдиницаИзмерения;
		КонецЕсли;
	КонецЦикла;
Списание.Записать(РежимЗаписиДокумента.Запись);
Возврат(Списание.Ссылка);
КонецФункции

&НаКлиенте
Процедура Рассчитать(Команда)
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
	Док = РассчитатьНаСервере();
	ОткрытьФорму("Документ.СписаниеМПЗПрочее.ФормаОбъекта",Новый Структура("Ключ",Док));
	КонецЕсли; 
КонецПроцедуры
