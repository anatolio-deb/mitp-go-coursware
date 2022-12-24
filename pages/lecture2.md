---
layout: cover
---

# Язык программирования Go
## Структура программы
### Анатолий Никифоров, МФТИ, 2023
#### Лекция 2

---

# Имена
- PascalCase и camelCase
- Имена начинаются с букв (по Unicode) или с нижнего подчерквивания
- В именах допустимы цифры и нижние подчеркивания
- Регистр имеет значение: `heapSort` и `Heapsort` – разные имена

## 25 ключевых слов

```
break        default      func         interface    select
case         defer        go           map          struct
chan         else         goto         package      switch
const        fallthrough  if           range        type
continue     for          import       return       var
```
<br/><br/>
Excerpt From
The Go Programming Language
Brian W. Kernighan
https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewBook?id=0
This material may be protected by copyright.

---

# Предварительно объявленные имена

<div class="text-xs">
    <div class="flex">
        <div class="flex-col text-base">
            Константы:
        </div>
        <div class="flex-col font-mono self-center mx-1">
            true  false  iota  nil
        </div>
    </div>
    <div class="flex">
        <div class="flex-col text-base">
            <div class="container mr-10 pt-4">
                Типы:
            </div>
        </div>
        <div class="flex-col font-mono mx-1">
            <p>
                int  int8  int16  int32  int64
            </p>
            <p>
                uint  uint8  uint16  uint32  uint64  uintptr
            </p>
            <p>
                float32  float64  complex128  complex64
            </p>
            <p>
                bool  byte  rune  string  error
            </p>
        </div>
    </div>
    <div class="flex">
        <div class="flex-col text-base">
            <div class="container mr-2 pt-4">
                Функции:
            </div>
        </div>
        <div class="flex-col font-mono mx-1">
            <p>
                make  len  cap  new  append  copy  close
            </p>
            <p>
                delete
            </p>
            <p>
                complex  real  imag
            </p>
            <p>
                panic  recover
            </p>
        </div>
    </div>
</div>

<div calss="text-sm">
    Excerpt From
    The Go Programming Language
    Brian W. Kernighan
    https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewBook?id=0
    This material may be protected by copyright.
</div>

---
---
# Имена

<v-clicks>

- Предварительно объявленные имена незарезервированы (доступны для объявлений).
- Сущность, объявленная в функции, _локальна_ для этой функции.
- Сущность, объявленная вне функции, видима во всех файлах пакета, которому она принадлежит.
- Первая заглавная буква объявления _экспортирует_ объявленную сущность в другие пакеты.
- Имена пакетов всегда в нижнем регистре
- Короткие имена предпочитетльны по соглашению
- Длинные имена преполагают особую смысловую нагрузку
- camel case и никакого snake case
    - **Хорошо**: `parseRequestDate`
    - **Плохо**: `parse_request_date`
- Аббревиатуры (HTML) остаются в верхнем регистре:
    - **Хорошо**: `ExportHTML`
    - **Плохо**: `ExportHtml`

</v-clicks>

---
---
# Объявления
<v-clicks>

- 4 главных типа объявлений: `var const type func`
- Исходный код прогарммы хранится в одном и более файлах с расширением `.go`
- Каждый файл начинается с объявления `package` - пакет, частью которого является файл
- После `package` следуют объявления любых `import`
- После `import` следуют объявления на уровне пакета (типы, переменные, константы, функции)

</v-clicks>

---
layout: two-cols
---

# Пример

```go
// Boiling prints the boiling point of water.
package main

import "fmt"

const boilingF = 212.0

func main() {
    var f = boilingF
    var c = (f - 32) * 5 / 9
    fmt.Printf("boiling point = %g°F or %g°C\n", f, c)
    // Output:
    // boiling point = 212°F or 100°C
}
```

Excerpt From
The Go Programming Language
Brian W. Kernighan
https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewBook?id=0
This material may be protected by copyright.

::right::

<div class="pt-14 pl-8">
    <ul>
        <li>Константа <span class="font-mono">boilingF</span> объявлена на уровне пакета <span class="font-mono">main</span></li>
        <li>Переменные <span class="font-mono">f</span> и <span class="font-mono">c</span> локальны для функции <span class="font-mono">main</span></li>
        <li><span class="font-mono">boilingF</span> видна во всех файлах пакета <span class="font-mono">main</span></li>
        <li><span class="font-mono">f</span> и <span class="font-mono">c</span> видны только в функции <span class="font-mono">main</span></li>
    </ul>
</div>

---
layout: two-cols
---

# Пример

```go
// Ftoc prints two Fahrenheit-to-Celsius conversions.
package main

import "fmt"

func main() {
    const freezingF, boilingF = 32.0, 212.0
    fmt.Printf("%g°F = %g°C\n", freezingF, fToC(freezingF)) // "32°F = 0°C
    fmt.Printf("%g°F = %g°C\n", boilingF, fToC(boilingF))   // "212°F = 100°C"
}

func fToC(f float64) float64 {
    return (f - 32) * 5 / 9
}
```

Excerpt From
The Go Programming Language
Brian W. Kernighan
https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewBook?id=0
This material may be protected by copyright.

::right::

<div class="pt-14 pl-8">
    <ul>
        <li>Объявление функции может включать опциональный список результатов</li>
        <li>Объявление параметров функции сопровождается указанием типов</li>
        <li>Если функция ничего не возвращает, список результатов в объявлении опускается.</li>
    </ul>
</div>
---

---
layout: end
---