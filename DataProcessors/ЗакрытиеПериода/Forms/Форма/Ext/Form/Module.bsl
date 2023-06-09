﻿
&НаСервере
Процедура ЗаполнитьОстаткиБракаПроизводстваНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	БракПроизводстваОстатки.МестоХранения КАК МестоХранения,
	|	БракПроизводстваОстатки.ПроизводственноеЗадание,
	|	БракПроизводстваОстатки.Линейка КАК Линейка,
	|	БракПроизводстваОстатки.РабочееМесто,
	|	БракПроизводстваОстатки.Изделие,
	|	БракПроизводстваОстатки.ВидБрака,
	|	БракПроизводстваОстатки.ЭтапЖизненногоЦикла,
	|	БракПроизводстваОстатки.Документ,
	|	БракПроизводстваОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.БракПроизводства.Остатки(&НаДату, ) КАК БракПроизводстваОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Линейка,
	|	МестоХранения
	|ИТОГИ ПО
	|	Линейка";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковБракаПроизводства.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков брака производства на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаЛинейки = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейки.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковБракаПроизводства.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Линейка = ВыборкаЛинейки.Линейка;
		Док.Комментарий = "Ввод остатков брака производства на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Линейка = ВыборкаЛинейки.Линейка;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаЛинейки.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковБракаПроизводства.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Линейка = ВыборкаЛинейки.Линейка;
			Док.Комментарий = "Ввод остатков брака производства на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
		ТЧ.МестоХранения = ВыборкаДетальныеЗаписи.МестоХранения;
		ТЧ.ПроизводственноеЗадание = ВыборкаДетальныеЗаписи.ПроизводственноеЗадание;
		ТЧ.РабочееМесто = ВыборкаДетальныеЗаписи.РабочееМесто;
		ТЧ.ВидБрака = ВыборкаДетальныеЗаписи.ВидБрака;
		ТЧ.ЭтапЖизненногоЦикла = ВыборкаДетальныеЗаписи.ЭтапЖизненногоЦикла;
		ТЧ.Изделие = ВыборкаДетальныеЗаписи.Изделие;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.Документ = ВыборкаДетальныеЗаписи.Документ;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.Документ);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиЗаказовПоставщикамНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаказыПоставщикамОстатки.Контрагент КАК Контрагент,
	|	ЗаказыПоставщикамОстатки.Договор КАК Договор,
	|	ЗаказыПоставщикамОстатки.ДатаИсполнения,
	|	ЗаказыПоставщикамОстатки.МПЗ КАК МПЗ,
	|	ЗаказыПоставщикамОстатки.ЗаказПоставщику,
	|	ЗаказыПоставщикамОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ЗаказыПоставщикам.Остатки(&НаДату, ) КАК ЗаказыПоставщикамОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент,
	|	МПЗ
	|ИТОГИ ПО
	|	Контрагент";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковЗаказовПоставщикам.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков заказов поставщикам на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаКонтрагенты = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаКонтрагенты.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковЗаказовПоставщикам.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
		Док.Комментарий = "Ввод остатков заказов поставщикам на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаКонтрагенты.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковЗаказовПоставщикам.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
			Док.Комментарий = "Ввод остатков заказов поставщикам на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
			Если ТипЗнч(ВыборкаДетальныеЗаписи.МПЗ) = Тип("СправочникСсылка.Материалы") Тогда
			ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Материалы;
			Иначе	
			ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Полуфабрикаты;
			КонецЕсли; 
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.ЗаказПоставщику = ВыборкаДетальныеЗаписи.ЗаказПоставщику;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.ЗаказПоставщику);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиЗаявокНаЗакупкуНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаявкиНаЗакупкуОстатки.Подразделение КАК Подразделение,
	|	ЗаявкиНаЗакупкуОстатки.МПЗ КАК МПЗ,
	|	ЗаявкиНаЗакупкуОстатки.ЗаявкаНаЗакупку,
	|	ЗаявкиНаЗакупкуОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ЗаявкиНаЗакупку.Остатки(&НаДату, ) КАК ЗаявкиНаЗакупкуОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Подразделение,
	|	МПЗ
	|ИТОГИ ПО
	|	Подразделение";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковЗаявокНаЗакупку.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков заявок на закупку на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаПодразделения = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаПодразделения.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковЗаявокНаЗакупку.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Подразделение = ВыборкаПодразделения.Подразделение;
		Док.Комментарий = "Ввод остатков заявок на закупку на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Подразделение = ВыборкаПодразделения.Подразделение;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаПодразделения.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковЗаявокНаЗакупку.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Подразделение = ВыборкаПодразделения.Подразделение;
			Док.Комментарий = "Ввод остатков заявок на закупку на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить(); 
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.ЗаявкаНаЗакупку = ВыборкаДетальныеЗаписи.ЗаявкаНаЗакупку;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.ЗаявкаНаЗакупку);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиЗаявокОтПокупателейНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаявкиОтПокупателейОстатки.Контрагент КАК Контрагент,
	|	ЗаявкиОтПокупателейОстатки.Договор КАК Договор,
	|	ЗаявкиОтПокупателейОстатки.ДатаИсполнения,
	|	ЗаявкиОтПокупателейОстатки.МПЗ КАК МПЗ,
	|	ЗаявкиОтПокупателейОстатки.ЗаявкаОтПокупателя,
	|	ЗаявкиОтПокупателейОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ЗаявкиОтПокупателей.Остатки(&НаДату, ) КАК ЗаявкиОтПокупателейОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент,
	|	МПЗ
	|ИТОГИ ПО
	|	Контрагент";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковЗаявокОтПокупателей.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков заявок от покупателей на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаКонтрагенты = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаКонтрагенты.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковЗаявокОтПокупателей.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
		Док.Комментарий = "Ввод остатков заявок от покупателей на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаКонтрагенты.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковЗаявокОтПокупателей.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Контрагент = ВыборкаКонтрагенты.Контрагент;
			Док.Комментарий = "Ввод остатков заявок от покупателей на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
			Если ТипЗнч(ВыборкаДетальныеЗаписи.МПЗ) = Тип("СправочникСсылка.Материалы") Тогда
			ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Материалы;
			Иначе	
			ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Полуфабрикаты;
			КонецЕсли; 
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.ЗаявкаОтПокупателя = ВыборкаДетальныеЗаписи.ЗаявкаОтПокупателя;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.ЗаявкаОтПокупателя);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиНаличныхМПЗНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОстатки.МестоХранения КАК МестоХранения,
	|	МестаХраненияОстатки.ВидМПЗ КАК ВидМПЗ,
	|	МестаХраненияОстатки.МПЗ КАК МПЗ,
	|	МестаХраненияОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.МестаХранения.Остатки(&НаДату, ) КАК МестаХраненияОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	МестоХранения,
	|	ВидМПЗ,
	|	МПЗ
	|ИТОГИ ПО
	|	МестоХранения";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковМПЗ.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков по местам хранения на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаМестоХранения = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМестоХранения.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковМПЗ.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.МестоХранения = ВыборкаМестоХранения.МестоХранения;
		Док.Комментарий = "Ввод остатков по местам хранения на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.МестоХранения = ВыборкаМестоХранения.МестоХранения;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаМестоХранения.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковМПЗ.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.МестоХранения = ВыборкаМестоХранения.МестоХранения;
			Док.Комментарий = "Ввод остатков по местам хранения на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
		ТЧ.ВидМПЗ = ВыборкаДетальныеЗаписи.ВидМПЗ;
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.Цена = ОбщийМодульВызовСервера.ПолучитьСтоимостьМПЗ(ВыборкаДетальныеЗаписи.МПЗ,1,Объект.ДатаОкончанияПериода);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиПередачВПроизводствоНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПередачиВПроизводствоОстатки.Документ КАК Документ,
	|	ПередачиВПроизводствоОстатки.ВидМПЗ КАК ВидМПЗ,
	|	ПередачиВПроизводствоОстатки.МПЗ КАК МПЗ,
	|	ПередачиВПроизводствоОстатки.КоличествоОстаток КАК КоличествоОстаток,
	|	ПередачиВПроизводствоОстатки.Документ.Линейка КАК Линейка
	|ИЗ
	|	РегистрНакопления.ПередачиВПроизводство.Остатки(&НаДату, ) КАК ПередачиВПроизводствоОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Линейка,
	|	Документ,
	|	ВидМПЗ,
	|	МПЗ
	|ИТОГИ ПО
	|	Линейка";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковПередачВПроизводство.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков передач в производство на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаЛинейка = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейка.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковПередачВПроизводство.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Линейка = ВыборкаЛинейка.Линейка;
		Док.Комментарий = "Ввод остатков передач в производство на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Линейка = ВыборкаЛинейка.Линейка;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаЛинейка.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковПередачВПроизводство.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Линейка = ВыборкаЛинейка.Линейка;
			Док.Комментарий = "Ввод остатков передач в производство на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
		ТЧ.Документ = ВыборкаДетальныеЗаписи.Документ;
		ТЧ.ВидМПЗ = ВыборкаДетальныеЗаписи.ВидМПЗ;
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиПередачНаЛинейкиНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПередачиНаЛинейкиОстатки.МестоХранения КАК МестоХранения,
	|	ПередачиНаЛинейкиОстатки.НомерЯчейки КАК НомерЯчейки,
	|	ПередачиНаЛинейкиОстатки.ВидМПЗ КАК ВидМПЗ,
	|	ПередачиНаЛинейкиОстатки.МПЗ КАК МПЗ,
	|	ПередачиНаЛинейкиОстатки.ПередачаНаЛинейку,
	|	ПередачиНаЛинейкиОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ПередачиНаЛинейки.Остатки(&НаДату, ) КАК ПередачиНаЛинейкиОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	МестоХранения,
	|	ВидМПЗ,
	|	МПЗ,
	|	НомерЯчейки
	|ИТОГИ ПО
	|	МестоХранения";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковПередачНаЛинейки.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков передач на линейки на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаМестаХранения = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМестаХранения.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковПередачНаЛинейки.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.МестоХранения = ВыборкаМестаХранения.МестоХранения;
		Док.Комментарий = "Ввод остатков передач на линейки на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.МестоХранения = ВыборкаМестаХранения.МестоХранения;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаМестаХранения.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковПередачНаЛинейки.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.МестоХранения = ВыборкаМестаХранения.МестоХранения;
			Док.Комментарий = "Ввод остатков передач на линейки на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
		ТЧ.НомерЯчейки = ВыборкаДетальныеЗаписи.НомерЯчейки;
		ТЧ.ВидМПЗ = ВыборкаДетальныеЗаписи.ВидМПЗ;
		ТЧ.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.ПередачаНаЛинейку = ВыборкаДетальныеЗаписи.ПередачаНаЛинейку;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.ПередачаНаЛинейку);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОстаткиПлановВыпусковНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПланыВыпускаОстатки.Подразделение,
	|	ПланыВыпускаОстатки.Линейка КАК Линейка,
	|	ПланыВыпускаОстатки.Номенклатура КАК Номенклатура,
	|	ПланыВыпускаОстатки.МаршрутнаяКарта,
	|	ПланыВыпускаОстатки.КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки(&НаДату, ) КАК ПланыВыпускаОстатки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Линейка,
	|	Номенклатура
	|ИТОГИ ПО
	|	Линейка";
Запрос.УстановитьПараметр("НаДату",КонецДня(Объект.ДатаОкончанияПериода));
Результат = Запрос.Выполнить();
Док = Документы.ВводОстатковПлановВыпуска.СоздатьДокумент();
Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
Док.Комментарий = "Ввод остатков планов выпуска на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
ВыборкаЛинейки = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейки.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводОстатковПлановВыпуска.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
		Док.Линейка = ВыборкаЛинейки.Линейка;
		Док.Комментарий = "Ввод остатков планов выпуска на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
		Иначе
		Док.Линейка = ВыборкаЛинейки.Линейка;
	    КонецЕсли;
	ВыборкаДетальныеЗаписи = ВыборкаЛинейки.Выбрать();
    	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
			Док.Записать(РежимЗаписиДокумента.Запись);
			Объект.ДокументыПереноса.Добавить(Док.Ссылка);
			Док = Документы.ВводОстатковПлановВыпуска.СоздатьДокумент();
			Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
			Док.Линейка = ВыборкаЛинейки.Линейка;
			Док.Комментарий = "Ввод остатков планов выпуска на "+Формат(Объект.ДатаОкончанияПериода,"ДФ=dd.MM.yyyy");
			КонецЕсли; 
		ТЧ = Док.ТабличнаяЧасть.Добавить();
		ТЧ.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
		ТЧ.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;
		ТЧ.МаршрутнаяКарта = ВыборкаДетальныеЗаписи.МаршрутнаяКарта;
		//Объект.ОставляемыеДокументы.Добавить(ВыборкаДетальныеЗаписи.МаршрутнаяКарта);
		КонецЦикла;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ЗаполнитьЦеныМПЗНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЦеныСрезПоследних.Период,
	|	ЦеныСрезПоследних.МПЗ,
	|	ЦеныСрезПоследних.Цена,
	|	ЦеныСрезПоследних.ЦенаФактическая
	|ИЗ
	|	РегистрСведений.Цены.СрезПоследних(&НаДату, ) КАК ЦеныСрезПоследних";
	Запрос.УстановитьПараметр("НаДату",Объект.ДатаОкончанияПериода);
	Попытка
	Результат = Запрос.Выполнить();
	Исключение
	Сообщить("Системная ошибка выполнения запроса по регистру ""Цены""", "!");
	Возврат Ложь;
	КонецПопытки;
Док = Документы.ВводЦенМПЗ.СоздатьДокумент();
Выборка = Результат.Выбрать(ОбходРезультатаЗапроса.Прямой);
	Пока Выборка.Следующий() Цикл
		Если Док.ТабличнаяЧасть.Количество() = Объект.МаксКолСтрок Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
        Объект.ДокументыПереноса.Добавить(Док.Ссылка);
		Док = Документы.ВводЦенМПЗ.СоздатьДокумент();
		Док.Дата = КонецДня(Объект.ДатаОкончанияПериода);
	    КонецЕсли;
	ТЧ = Док.ТабличнаяЧасть.Добавить();
	ТЧ.МПЗ = Выборка.МПЗ;
	ТЧ.Цена = Выборка.Цена;
	ТЧ.ЦенаФактическая = Выборка.ЦенаФактическая;
	КонецЦикла;
		Если Док.ТабличнаяЧасть.Количество() > 0 Тогда
		Док.Записать(РежимЗаписиДокумента.Запись);
		Объект.ДокументыПереноса.Добавить(Док.Ссылка);
	    КонецЕсли;
Возврат(Истина);
КонецФункции

&НаСервере
Функция СоздатьДокументыВводаОстатковНаСервере()
//Формирование остатков на конец периода
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	ЗаполнитьОстаткиБракаПроизводстваНаСервере();
	ЗаполнитьОстаткиЗаказовПоставщикамНаСервере();
	ЗаполнитьОстаткиЗаявокНаЗакупкуНаСервере();
	ЗаполнитьОстаткиЗаявокОтПокупателейНаСервере();
	ЗаполнитьОстаткиНаличныхМПЗНаСервере();
	ЗаполнитьОстаткиПередачВПроизводствоНаСервере();
	ЗаполнитьОстаткиПередачНаЛинейкиНаСервере();
	ЗаполнитьОстаткиПлановВыпусковНаСервере();
	ЗаполнитьЦеныМПЗНаСервере();
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Возврат(Истина);
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	КонецПопытки;
Возврат(Ложь); 
КонецФункции

&НаСервере
Процедура ПометитьНаУдалениеУстаревшиеДокументыНаСервере()
	Для Сч = 0 По Метаданные.Документы.Количество()-1 Цикл
	ОбъектМетаданныхДокумент = Метаданные.Документы.Получить(СЧ);
	Выборка = Документы[ОбъектМетаданныхДокумент.Имя].Выбрать(,Объект.ДатаОкончанияПериода);
		Пока Выборка.Следующий() Цикл
			Если Выборка.ПометкаУдаления Тогда
			Продолжить;
			КонецЕсли; 
				Если Объект.ДокументыПереноса.НайтиПоЗначению(Выборка.Ссылка) = Неопределено Тогда
				ДокУдаления = Выборка.ПолучитьОбъект();
				ДокУдаления.УстановитьПометкуУдаления(Истина);
				КонецЕсли; 
		КонецЦикла; 
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ПровестиДокументыВводаОстатковНаСервере()
	Для каждого ДокументПереноса Из Объект.ДокументыПереноса Цикл
  	Док = ДокументПереноса.Значение.ПолучитьОбъект();
	Док.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный); 
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗакрытие(Команда)
	Если СоздатьДокументыВводаОстатков Тогда
	Состояние("Обработка...",,"Создание документов ввода остатков...");
		Если Не СоздатьДокументыВводаОстатковНаСервере() Тогда
		Возврат;
		КонецЕсли; 
	Сообщить(ТекущаяДата());	
	КонецЕсли;
		Если ПометитьНаУдалениеУстаревшиеДокументы Тогда
		Состояние("Обработка...",,"Пометка на удаление устаревших документов...");
		ПометитьНаУдалениеУстаревшиеДокументыНаСервере();
		Сообщить(ТекущаяДата());
		КонецЕсли;
			Если ПровестиДокументыВводаОстатков Тогда
			Состояние("Обработка...",,"Проведение документов ввода остатков...");
			ПровестиДокументыВводаОстатковНаСервере();
			Сообщить(ТекущаяДата());
			КонецЕсли;  
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
Объект.ДатаОкончанияПериода = НачалоГода(ТекущаяДата())-3600;
Объект.МаксКолСтрок = 100;
КонецПроцедуры
