﻿&НаСервере
Функция ПолучитьКаталог()
Возврат(ПолучитьТекущийКаталог(Объект.Родитель));
КонецФункции

&НаСервере
Функция ПолучитьИмяФайла()
Возврат(Объект.ИмяФайла);
КонецФункции	

&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)	
Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
Диалог.Заголовок = "Выберите файл";
Диалог.Каталог = ПолучитьКаталог();
Диалог.ПолноеИмяФайла = ""; 
Фильтр = "Все файлы (*.*)|*.*"; 
Диалог.Фильтр = Фильтр; 
Диалог.МножественныйВыбор = Ложь;
	Если Диалог.Выбрать() Тогда
	Файл = Новый Файл(Диалог.ВыбранныеФайлы[0]);
	Объект.ИмяФайла = Файл.Имя;
	Объект.Наименование = Файл.ИмяБезРасширения;
		Если Найти(Файл.ИмяБезРасширения,"(") = 1 Тогда
		ТекКод = Лев(Файл.ИмяБезРасширения,Найти(Файл.ИмяБезРасширения,")")-1);
		Объект.Код = Число(Прав(ТекКод,СтрДлина(ТекКод)-1));
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ИзвещениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок = "Выберите файл";
	Диалог.Каталог = ПолучитьКаталог();
	Диалог.ПолноеИмяФайла = ""; 
	Фильтр = "Файл извещения (*.pdf)|*-*.pdf"; 
	Диалог.Фильтр = Фильтр; 
    Диалог.МножественныйВыбор = Ложь;
		Если Диалог.Выбрать() Тогда
		Файл = Новый Файл(Диалог.ВыбранныеФайлы[0]);
		Объект.Извещение = Файл.Имя;
		КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Объект.ИмяФайла = "" Тогда
	Элементы.ДанныеПоФайлу.Заголовок = "файл не выбран";
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
Файл = Новый Файл(ПолучитьКаталог()+ПолучитьИмяФайла());
	Если Файл.Существует() Тогда
		Если Не Файл.ЭтоКаталог() Тогда
		Элементы.ДанныеПоФайлу.Заголовок = "Размер: "+Файл.Размер()+" байт; дата создания: "+Файл.ПолучитьВремяИзменения();
		КонецЕсли; 
	КонецЕсли; 
КонецПроцедуры
