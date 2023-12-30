# plotter-text

Generate dynamic single-stroke text in Processing. Save to SVG for clean pen plotter output.

![banner](banner.png)

## Getting Started

### Requirements

1. [Processing 4](https://processing.org/download/)

### Installation

#### Copy the PlotterText Class to Your Project

Copy the `PlotterText.pde` file from the `dist` folder into the folder for your Processing sketch.

#### Copy the Font Files (or Create Your Own)

Copy the entire [`astroTown`](/fonts/astroTown/) font folder into your sketch's `data` folder.

If you want to create your own font, you'll need an SVG file for each character and a `data.json` file to specify font coordinates. Use the [Font Editor](examples/FontEditor/) in the `examples` folder to edit character positions and kerning pairs.

### Example Sketch

1. Create an instance of the `PlotterText` class with the path to your font.
2. Use `drawText()` or `drawTextCentered()` to render text to the screen.

```java
PlotterText pt;

void setup() {
  size(300, 200);
  pt = new PlotterText("fonts/astroTown/", 20);
}

void draw() {
  background(255);
  pt.drawText("Hello world!", 10, 10);
}

```

## Usage

### Drawing Text

`drawText(text)`
`drawText(text, x, y)`

`drawTextCentered(text, x, y)`

### Font Properties

`setSize(size)`

### Saving

`saveData()`

### Save to SVG

## Build from Source

The build script for this project (`build.sh`) simply copies the classes from `src` into a single file in the `dist` folder.

```zsh
cd [plotter-text]
./build.sh
```

## Support

This is a personal project and is mostly unsupported, but I'm happy to hear feedback or answer questions.

## License

This project is licensed under the Unlicense - see the [LICENSE](LICENSE) file for details.

---

👨🏻‍🦲❤️🛠
