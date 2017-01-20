## Prepare

```
    npm install -g elm
```

## Build app

```
    make
```

## Install

Add `./dist` direcrory to `chrome://extensions/` as unpacked extension.

Enjoy.

## Build standalone app

Я, блядь, ссу кипятком. Не думал что доживу до такого.
Собираем самодостаточное кроссплатформенное, мать его, приложение.

```
    make app
```

Или через npm все системы

```
    make all
    npm prod
```

Только linux64

```
    make all
    npm prod-linux64
```


## Сборка инсталлятора

Под маком (инструкция не завершена):

```
npm install -g appdmg
appdmg dmg.json InsteadMan-2.0.1.dmg
```

См https://github.com/1000tech/insteadman/blob/master/build/mac/dmg.json

И тут: https://github.com/ankurk91/node-webkit-angular-starter-kit/tree/b4117bcee81c57d59ea1dd56de0d8d010a7ef04a/resources/osx


## Отладка под NWjs

```
    npm i
    npm run dev
```

## Заметки на будущее

Тут
https://github.com/paramanders/elm-twitch-chat
вроде самый простой и очевидный способ реализации компонентов.

Посмотреть что это за HTML.lazy и с чем его едят
https://github.com/evancz/elm-todomvc/blob/master/Todo.elm
