---
layout: cover
---

# Язык программирования Go
## История, особенности и возможности
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 1

---

# Обо мне
<div class="flex">
    <img src="/IMG_2194.jpg" class="mx-10 h-40 rounded shadow flex-col"/>
    <div class="flex-col">
        <ul>
            <li> Бакалавр компьютерной инженерии, ХНУРЭ, 2015</li>
            <li> Lead Go Engineer at ForestVPN: <a href="https://forestvpn.com/about/"> https://forestvpn.com/about/</a></li>
            <li> JetBrains Academy contributor </li>
            <li> Anyd framework: <a href="https://pypi.org/project/anyd/"> https://pypi.org/project/anyd/</a></li>
        </ul>
    </div>
</div>

---

# Связь со мной

<div class="flex py-1">
    <div class="flex-col self-center px-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Circle-icons-mail.svg/1024px-Circle-icons-mail.svg.png" class="h-5"/>
    </div>
    <a class="flex-col" href="mailto:nikiforova693@gmail.com">nikiforova693@gmail.com</a>
</div>
<div class="flex py-1">
    <div class="flex-col self-center px-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Octicons-mark-github.svg/2048px-Octicons-mark-github.svg.png" class="h-5"/>
    </div>
    <a class="flex-col" href="https://github.com/anatolio-deb">@anatolio-deb</a>
</div>
<div class="flex py-1">
    <div class="flex-col self-center px-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/LinkedIn_icon_circle.svg/640px-LinkedIn_icon_circle.svg.png" class="h-5"/>
    </div>
    <a class="flex-col" href="https://linkedin.com/in/anatolio-nikiforidis/">https://linkedin.com/in/anatolio-nikiforidis</a>
</div>
<div class="flex py-1">
    <div class="flex-col self-center px-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Telegram_logo.svg/2048px-Telegram_logo.svg.png" class="h-5"/>
    </div>
    <a class="flex-col" href="https://t.me/anatolio_nikiforidis">@anatolio_nikiforidis</a>
</div>
<div class="flex py-1">
    <div class="flex-col self-center px-3">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Telegram_logo.svg/2048px-Telegram_logo.svg.png" class="h-5"/>
    </div>
    <a class="flex-col" href="https://t.me/bachelorscoding">@bachelorscoding</a>
</div>

---

# О курсе

- Лекции
- Семинары
- Домашние работы
- Проекты

---

# Полезные ссылки

- Группа в Telegram
- Go Playground: [https://go.dev/play/](https://go.dev/play/)
- Go talks: [https://go.dev/talks/](https://go.dev/talks/)
- [https://yourbasic.org/](https://yourbasic.org/)
- [https://gobyexample.com/](https://gobyexample.com/)

---

# Литература

<div class="flex">
    <div class="container flex-col">
        <img src="https://www.gopl.io/cover.png" class="h-50 shadow"/>
        <p class="text-xs">Доступна в переводе (Вильямс)</p>
    </div>
    <div class="container flex-col">
        <img src="https://m.media-amazon.com/images/I/51f9LBAOxOL._SX404_BO1,204,203,200_.jpg" class="h-50 shadow"/>
        <p class="text-xs">Доступна в переводе (Питер)</p>
    </div>
    <div class="container flex-col">
        <img src="https://m.media-amazon.com/images/I/51rGvcoSLxL.jpg" class="h-50 shadow"/>
    </div>
</div>

- **The Go Programming Language**, Alan A. A. Donovan and Brian W. Kernighan, 2015, *Addison-Wesley*
- **Mastering Go: Harness the power of Go to build professional utilities and concurrent servers and services, 3rd Edition**, Mihalis Tsoukalos, 2021, *Packt Publishing*
- **Introducing Go: Build Reliable, Scalable Programs**, Caleb Doxsey, 2016, *O'Reilly Media*

---

# Литература в свободном доступе

- **Go Bootcamp,** Matt Aimonetti: [http://www.golangbootcamp.com/book](http://www.golangbootcamp.com/book)
- **An Introduction to Programming in Go,** Caleb Doxsey: [https://www.golang-book.com/](https://www.golang-book.com/)
- **Building Web Apps** with Go by Jeremy Saenz: [https://github.com/faun/building-web-apps-with-go](https://github.com/faun/building-web-apps-with-go)
- **The Little Go Book,** Karl Seguin: [https://www.openmymind.net/The-Little-Go-Book/](https://www.openmymind.net/The-Little-Go-Book/)

*Список неплоный*

---

# История

<div class="flex">
    <div class="container flex-col">
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Robert_Griesemer.jpg/1024px-Robert_Griesemer.jpg" class="h-50 shadow"/>
        <p>Robert Griesemer</p>
    </div>
    <div class="container flex-col">
        <img src="https://upload.wikimedia.org/wikipedia/commons/f/f8/Ken-Thompson-2019.png" class="h-50 shadow"/>
        <p>Ken Thompson</p>
    </div>
    <div class="container flex-col">
        <img src="https://upload.wikimedia.org/wikipedia/commons/9/9c/Rob-pike-oscon.jpg" class="h-50 shadow"/>
        <p>Rob Pike</p>
    </div>
</div>

<v-clicks>

- Разработан в Google
- Консолидирует дизайн Algol60, Pacal, C, Modula/2, (Object) Oberon/2
- Минимализм: один способ сделать что-то
- Выражать <span class="font-bold">алгоритмы</span>, а не систему типов
- Нужна была многопоточность и контроль зависимостей

</v-clicks>

---

# ~10 лет Go

<img src="/Screenshot_2022-12-08_at_18.30.54.png" class="h-100"/>

---

# Какие проблемы решает Go

> «Go был разработан для решения реальных проблем, возникающих при разработке программного обеспечения в Google» — Роб Пайк
> 
<v-clicks>

- Медленную сборку программ
- Неконтролируемые зависимости
- Использование разными программистами разных подмножеств языка
- Затруднения с пониманием программ, вызванные неудобочитаемостью кода, плохим документированием и так далее
- Дублирование разработок
- Высокую стоимость обновлений
- Несинхронные обновления при дублировании кода
- Сложность разработки инструментария
- Проблемы межъязыкового взаимодействия

</v-clicks>

---

# Ключевые особенности

<v-clicks class="text-sm">

- Автоматическое управление памятью (сборщик мусора)
- Компиляция в объектный код
- Статическая типизация
- Нет иерархий типов
- Нет неявных преобразований типов
- Указатели без арифметики
- Сборка под каждую платформу
- Пакеты и модули
- Контроль зависимостей
- Утиная типизация
- ООП
- Простые синтаксические конструкции
- Минимум абстракций
- Минимум ключевых слов
- Синтаксический сахар

</v-clicks>


---

# Go сегодня

<a href="https://github.com/golang/go/wiki/GoUsers">https://github.com/golang/go/wiki/GoUsers</a>

<div class="w-xl">
    <img src="/Screenshot 2022-12-29 at 00.51.42.png"/>
</div>
---
---

# Open Source проекты на Go (мой опыт)

- dnscrypt-proxy — реализация dnscrypt, а затем DoH, переписан с Си со второй версии
- v2ray — реализует собственный сетевые протоколы (vmess, vless)
- traefik — современный прокси сервер, замена NGINX
- cloudflared — туннель для проксирования DNS запросов
- GitHub CLI – комнадная строка от GitHub
- go-shadowsocks2 – современная реализация shadowsocks

---

# Поиск узла дерева на Oberon-2

```
MODULE Trees;

IMPORT Texts, Oberon;

TYPE
    Tree* = POINTER TO Node;  (* star denotes export, not pointer! *)
    Node* = RECORD
        name-: POINTER TO ARRAY OF CHAR;  (* minus denotes read-only export *)
        left, right: Tree
    END;

PROCEDURE (t: Tree) Lookup* (name: ARRAY OF CHAR): Tree;
    VAR p: Tree;
BEGIN p := t;
    WHILE (p # NIL) & (name # p.name^) DO
        IF name < p.name^ THEN p := p.left ELSE p := p.right END
    END;
    RETURN p
END Lookup;

...
```

---

# Аналог на Go

```go
package trees

import ( "fmt"; "runtime" )

type (
    Tree *Node
    Node struct {
        name        string
        left, right Tree
    }
)

func (t *Node) Lookup(name string) Tree {
    var p Tree
    p = t
    for p != nil && name != p.name {
        if name < p.name { p = p.left } else { p = p.right }
    }
    return p
}

...
```

---

# Наблюдения

- Отличается синтаксис, но не структура
    - Токены C, структура Oberon
- Похожие идеи (пакеты, импорты, типы, функции/методы и т.д.)
    - Концепции Go в дальнейшем упрощаются (например единственная конструкция цикла)

Go наследует Oberon по крайней мере на столько же, насколько он наследует C (пакеты, импорты, строгая безопасность памяти, сборка мусора, динамическая проверка типов, и т.д.)

---

# ООП и обобщения

Около 1990: ООП и системы типов захватывают языки программирования

- C++, Java и другие
- Сложные объектно-ориентированные системы типов
- Сложные системы обобщенных типов

Распространение динамически-типизированных, интерпретируемых языков:

- Erlang, Perl, Python, Lua, Javascript, Ruby и т.д.

1990, 2000:

- Сложный ООП код – современный аналог неструктурированного "спагетти кода” из 1970
- Осознание того, что большие программы, написанные на динамически-типизированных языках невозможно поддерживать
- Беспорядочная запись: `public static void` (Rob Pike, OSCON 2010)

---

# Интерфейсы

Вдохновение: Smalltalk (Alan Kay, Dan Ingalls, Adele Goldberg, 1972-1980):

- Все есть объект.
- Любое сообщение можно отправить любому объекту.

Хотелось: силы статически-типизированных языков без сложностей системы типов.

- Понятие интерфейсов для статической типизации.
- Обычно объекты несут информацию о типе ⇒ ограничивает типы объектов «классами».

**Важно понимать**: методы можно определять любому типу если информацию от типе несет интерфейс, а не объекты.

Методы и интерфейсы — дополнительные механизмы, необходимые для ООП.

---

# Что делает язык успешным?

<v-clicks>

- Четкая цель
- Строгая реализация: язык, библиотеки, инструменты
- Готовность рынка
- Технологический прорыв
- Отсутствие конкуренции подходов внутри языка
- Редко: реклама

</v-clicks>

---

# Что насчет Go?

<v-clicks>

- За дизайном стоит четкая цель
- Мультипарадигмальность (императивный, функциональный, объектно-ориентированный)
- Простой синтаксис
- Фичи языка без конкурентов: горутины, интерфейсы, defer
- Инструменты без конкурентов: быстрый компилятор, gofmt, go build
- Сильная стандартная библиотека
- Строгая реализация
- Превосходная документация, ресурсы онлайн (playground, tour)
- Ни о каком корпоративном маркетинге не может быть и речи

</v-clicks>

---

# Заключение

- В 1960 эксперты из Америки и Европы объединились в команду чтобы сделать Algol 60
- В 1970 дерево Algol 60 разветвилось на C и Pascal
- ~40 годами позже две ветки снова объединились в Go
- Go больше 10 лет, и его популярность продолжает расти

---
layout: end
---