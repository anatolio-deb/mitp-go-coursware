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
layout: end
---