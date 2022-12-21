# Лекция 1. Язык программирования Go
## История, особенности и возможности Go
### Анатолий Никифоров, МФТИ, 2023

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

- [nikiforova693@gmail.com](mailto:nikiforova693@gmail.com)
- [@anatolio_nikiforidis](http://t.me/anatolio_nikiforidis) — Telegram
- [@bachelorscoding](http://t.me/bachelorscoding) (канал)

---

# О курсе

- Лекции
- Домашние работы
- Тесты
- Баллы

---

# Полезные ссылки

- Группа в Telegram
- Go Playground: [https://go.dev/play/](https://go.dev/play/)
- Go talks: [https://go.dev/talks/](https://go.dev/talks/)
- Что-то еще

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

<ul>
    <li v-click>Разработан в Google</li>
    <li v-click>Консолидирует дизайн Algol60, Pacal, C, Modula/2, (Object) Oberon/2</li>
    <li v-click>Минимализм: один способ сделать что-то</li>
    <li v-click>Выражать <span class="font-bold">алгоритмы</span>, а не систему типов</li>
    <li v-click>Нужна была многопоточность и контроль зависимостей</li>
</ul>

---

# ~10 лет Go

<img src="/Screenshot_2022-12-08_at_18.30.54.png" class="h-100"/>

---

# Какие проблемы решает Go

> «Go был разработан для решения реальных проблем, возникающих при разработке программного обеспечения в Google» — Роб Пайк
> 
<ul>
    <li v-click>Медленную сборку программ</li>
    <li v-click>Неконтролируемые зависимости</li>
    <li v-click>Использование разными программистами разных подмножеств языка</li>
    <li v-click>Затруднения с пониманием программ, вызванные неудобочитаемостью кода, плохим документированием и так далее</li>
    <li v-click>Дублирование разработок</li>
    <li v-click>Высокую стоимость обновлений</li>
    <li v-click>Несинхронные обновления при дублировании кода</li>
    <li v-click>Сложность разработки инструментария</li>
    <li v-click>Проблемы межъязыкового взаимодействия</li>
</ul>

---

# Ключевые особенности

<ul class="text-xs">
    <li v-click>Автоматическое управление памятью (сборщик мусора)</li>
    <li v-click>Компиляция в объектный код</li>
    <li v-click>Статическая типизация</li>
    <li v-click>Нет иерархий типов</li>
    <li v-click>Нет неявных преобразований типов</li>
    <li v-click>Указатели без арифметики</li>
    <li v-click>Сборка под каждую платформу</li>
    <li v-click>Пакеты и модули</li>
    <li v-click>Контроль зависимостей</li>
    <li v-click>Утиная типизация</li>
    <li v-click>ООП</li>
    <li v-click>Простые синтаксические конструкции</li>
    <li v-click>Минимум абстракций</li>
    <li v-click>Минимум ключевых слов</li>
    <li v-click>Синтаксический сахар</li>
</ul>

---

# Go сегодня

- Backend
- OS
    - Daemons
    - CLI
    - Protocols
- DevOps
    - Docker
    - Kubernetes
    - Terraform
    - OpenShift
    
---

# Проекты на Go

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

- Сложный ООП код – современный аналог неструктурированного "спегетти кода” из 1970
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

<ul>
    <li v-click> Четкая цель</li>
    <li v-click>Строгая реализация: язык, библиотеки, инструменты</li>
    <li v-click>Готовность рынка</li>
    <li v-click>Технологический прорыв</li>
    <li v-click>Отсутствие конкуренции подходов внутри языка</li>
    <li v-click>Редко: реклама</li>
</ul>

---

# Что насчет Go?

<ul>
    <li v-click>За дизайном стоит четкая цель</li>
    <li v-click>Мультипарадигменность (императивный, функциональный, объектно-ориентированный)</li>
    <li v-click>Простой синтаксис</li>
    <li v-click>Фичи языка без конкурентов: горутины, интерфейсы, defer</li>
    <li v-click>Инструменты без конкурентов: быстрый компилятор, gofmt, go build</li>
    <li v-click>Сильная стандартная библиотека</li>
    <li v-click>Строгая реализация</li>
    <li v-click>Превосходная документация, ресурсы онлайн (playground, tour)</li>
    <li v-click>Ни о каком корпоративном маркетинге не может быть и речи</li>
</ul>

---

# Заключение

- В 1960 эксперты из Америки и Европы объединились в команду чтобы сделать Algol 60
- В 1970 дерево Algol 60 разветвилось на C и Pascal
- ~40 годами позже две ветки снова объединились в Go
- Go больше 10 лет, и его популярность продолжает расти