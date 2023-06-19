# Website Video Screenshot Tool

This tool automates the process of taking screenshots of a webpage, labeling them with timestamps, and generating a video from these screenshots.

> **Note:** This tool was designed for macOS users. Other users might need to adjust the path to the Chrome executable accordingly.

## Coded by GPT4

This project is an example of how artificial intelligence can assist with software development. The bulk of the code and this README were written by GPT-4, an AI model developed by OpenAI, with guidance from a human about goals and assistance with running and testing the code.

## Installation

    bundle install


## Usage

The tool has three main commands: `capture`, `label`, and `video`.

### Capture

This command starts the process of capturing screenshots of the specified URL.

    bundle exec ruby webvidshot.rb capture URL [ENVIRONMENT]


**Options:**

- `--chrome-path` - Path to Chrome executable. Default is `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome`.
- `--label` - Start the labeling process to label screenshots with timestamps. Default is `true`.
- `--video` - Start the video generation process to update generated videos when new files appear or when any other changes happen to the environment's screenshot directory. Default is `true`.

**Description:**

Start capturing screenshots of the given URL and keep going indefinitely. Label each new screenshot with a timestamp and the name of the environment, "screenshots" by default. Generate a video of the screenshots and keep updating it when new files appear or when any other changes happen to the environment's screenshot directory.

### Label

This command starts the process of labeling screenshots with timestamps.

    bundle exec ruby webvidshot.rb label [ENVIRONMENT]


**Options:**

- `--watch` - Watch for changes over time and keep updating labels when new files appear or when any other changes happen to the environment's screenshot directory. Default is `true`.

**Description:**

Label existing screenshots with timestamps, and watch for new screenshots to label.

### Video

This command starts the process of generating a video from the screenshots.

    bundle exec ruby webvidshot.rb video [ENVIRONMENT]

**Description:**

Watch for changes to the screenshot directory and generate a video when new files appear or when any other changes happen to the environment's screenshot directory.

