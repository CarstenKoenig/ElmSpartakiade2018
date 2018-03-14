# Spartakiade 2018 - Elm Workshop
<p align="center"><img src="spartakiade.png" width=100/></p>

**18. und 18. März in Berlin**

Web:     http://spartakiade.org/

Twitter: http://twitter.com/spartakiade_org

---

[Workshop-Log](./Workshop.md)

---

## Linksammlung

### Elm
- [Homepage](http://elm-lang.org/)
- [Packages Docs](http://package.elm-lang.org/)
- [Syntax](http://elm-lang.org/docs/syntax)
- [Javascript -> Elm](http://elm-lang.org/docs/from-javascript)

### nützliche Docs
- [Elm Core](http://package.elm-lang.org/packages/elm-lang/core/latest/)
- [Elm Html](http://package.elm-lang.org/packages/elm-lang/html/latest/)
- [Elm Http](http://package.elm-lang.org/packages/elm-lang/http/latest)

### Hintergrund
- [Elm Records](http://elm-lang.org/docs/records)
- [the Elm Architecture](https://guide.elm-lang.org/architecture/)

### Tools
- [Installation](https://guide.elm-lang.org/install.html)
- [elm-format](https://github.com/avh4/elm-format#installation)
- [elm-oracle](https://github.com/ElmCast/elm-oracle)
- [vscode-elm](https://github.com/sbrink/vscode-elm)


## Installation
### Elm
Bitte Such Dir auf [dieser Seite](https://guide.elm-lang.org/install.html) einen entsprechenden Installer/Weg.
Dort findest Du:

- **Windows** - kann entweder als Installer oder über [NPM](https://www.npmjs.com/package/elm) installiert werden.
- **Mac** ebenfalls als Installer oder [NPM](https://www.npmjs.com/package/elm)
- **Linux** über [NPM](https://www.npmjs.com/package/elm)

installiert werden.

Persönlich bevorzuge ich den Weg über [**NPM**](https://www.npmjs.com/package/elm) weil das überall geht:

```
npm install -g elm
```

bzw.

```
sudo install -g elm
```

### Elm Format
*Elm Format* ist sehr nützlich (automatische Quellcodeformatierung) und ich empfehle es mit zu installieren, auch wenn es am Anfang etwas gewöhnungsbedürftig ist.

Mittlerweile ist [Elm Format auf npm](https://www.npmjs.com/package/elm-format), Du kannst aber auch die Binary irgendwo in Deinem Pfad ablegen.

Die Binaries findest Du hier [avh4/elm-format/releases](https://github.com/avh4/elm-format/releases)

### Elm Oracle
Manche Editor-Plugins (*elm-vim*, *atom-elm*, *elm-mode* (Emacs), *Elm.tmLanguage* (Sublime), *elm-light* (LightTable)) benötigen *Elm Oracle*.

Das VS.code Plugin erwähnt das nicht, aber soweit ich finden konnte benuttz das Plugin Oracle auch noch [Quelle](https://github.com/Krzysztof-Cieslak/vscode-elm/search?utf8=%E2%9C%93&q=oracle&type=)

Die Installation läuft über **NPM**:

```
npm install -g elm-oracle
```

bzw.

```
sudo npm install -g elm-oracle
```

### Editorsupport
#### VS.code
siehe [vscode-elm](https://marketplace.visualstudio.com/items?itemName=sbrink.elm)

#### Emacs
ist in [**MELPA** (`elm-mode`)](https://github.com/jcollard/elm-mode) verfügbar, *elm-oracle* und *elm-format* sollten installiert sein.

hier ist der relevante Teil meiner Emacs-Config:

### andere
siehe "Configure Your Editor" [hier](https://guide.elm-lang.org/install.html)