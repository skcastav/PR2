﻿
&НаКлиенте
Процедура ОК(Команда)
	Если ЗначениеЗаполнено(ПричинаОстановки) Тогда
	ЭтаФорма.Закрыть(Новый Структура("ПричинаОстановки,Комментарий",ПричинаОстановки,Комментарий));
	Иначе
	Сообщить("Выберите причину остановки МТК.");	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
ЭтаФорма.Закрыть(Неопределено);
КонецПроцедуры

