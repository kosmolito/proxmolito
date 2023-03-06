# Proxmolito
The idea behind proxmolito came from the need to create and configure Virtual Machines easily and quickly. The main goal is to create a tool that can be used by anyone, even if they have no knowledge of Virtual Machines. I am planning to add more features to proxmolito in the future, like the ability to create and configure containers, setups for host networking, and more. But for now, I am focusing on the main goal of proxmolito, which is to create and configure Virtual Machines.

I hope you find this project useful and if you have any questions or suggestions, feel free to contact me at [email protected](mailto:said.karker@gmail.com).

## Installation
```bash
# Install git, if you don't have it already
apt update && apt install git -y

# Clone the repository
git clone https://github.com/kosmolito/proxmolito.git

# Change directory to proxmolito
cd proxmolito

# Make setup.sh executable
chmod +x setup.sh

# install the dependencies incl. PowerShell
./setup.sh
```

## Usage
```PowerShell
# Run PowerShell
pwsh
# Run proxmolito
./proxmolito.ps1
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Acknowledgements
* [Proxmox](https://www.proxmox.com/en/)
* [PowerShell](https://docs.microsoft.com/en-us/powershell/)

