# Bitbox RootFS

Bitbox RootFS is a project designed to provide a minimal and efficient root filesystem for embedded systems or lightweight Linux distributions.

## Features

- Lightweight and minimal root filesystem.
- Optimized for embedded systems.
- Easy to customize and extend.
- Compatible with various Linux distributions.

## Getting Started

### Prerequisites

To build and use Bitbox RootFS, ensure you have the following tools installed:

- GNU Make
- GCC (or a compatible cross-compiler)
- Required libraries and dependencies for your target platform

### Building the RootFS

1. Clone the repository:
    ```
    git clone https://github.com/daipham.3213/bitbox-rootfs.git
    cd bitbox-rootfs
    ```

2. Configure the build for your target platform:
    ```
    make configure TARGET=<your-target-platform>
    ```

3. Build the root filesystem:
    ```
    make
    ```

4. The built root filesystem will be available in the `output/` directory.

### Customization

You can customize the root filesystem by modifying the configuration files located in the `config/` directory. Refer to the documentation for detailed instructions.

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgments

Special thanks to all contributors and open-source projects that make this possible.