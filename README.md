### Note

This `README.md` documents the process of creating a `Virtual Hackintosh`
system on Manjaro
This repository is strictly for personal use

Note: All blobs and resources included in this repository are re-derivable (all
instructions are included!).

Working with `Proxmox` and macOS? See [Nick's blog for sure](https://www.nicksherlock.com/).


### Requirements

* A modern Linux distribution. E.g. Any Arch Based Distro

* QEMU >= 6.2.0

* A CPU with Intel VT-x / AMD SVM support is required (`grep -e vmx -e svm /proc/cpuinfo`)

* A CPU with SSE4.1 support is required for >= macOS Sierra

* A CPU with AVX2 support is required for >= macOS Mojave

Note: Older AMD CPU(s) are known to be problematic. AMD FX-8350 works but
Phenom II X3 720 does not. Ryzen processors work just fine.


### Installation Preparation

* KVM may need the following tweak on the host machine to work.

  ```
  echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
  ```

  To make this change permanent, you may use the following command.

  ```
  sudo cp kvm.conf /etc/modprobe.d/kvm.conf  # for intel boxes only, after cloning the repo below
  ```

* Install QEMU and other packages.

  ```
  sudo pacman -S qemu-desktop virt-manager git \
      wget p7zip make dmg2img -y
  ```

  This step may need to be adapted for your Linux distribution.

* Add user to the `kvm` and `libvirt` groups (might be needed).

  ```
  sudo usermod -aG kvm $(whoami)
  sudo usermod -aG libvirt $(whoami)
  sudo usermod -aG input $(whoami)
  ```

  Note: Re-login after executing this command.

* Clone this repository on your QEMU system. Files from this repository are
  used in the following steps.

  ```
  cd ~

  git clone --depth 1 --recursive https://github.com/Rednekol/OSX-KVM-Passthrough.git

  cd OSX-KVM-Passthrough
  ```

  Repository updates can be pulled via the following command:

  ```
  git pull --rebase
  ```

  This repository uses rebase based workflows heavily.

  Start isntallation by making the setup.sh script executable by 
  '''
  chmod +x setup.sh
  '''
  
  followed by:
  '''
  ./setup.sh
  '''
  

  Note: Modern NVIDIA GPUs are supported on HighSierra but not on later
  versions of macOS.



### Installation

  Let the install.sh script do it's thing

- (OPTIONAL) Use this macOS VM disk with libvirt (virt-manager / virsh stuff).

  - Edit `macOS-libvirt-Catalina.xml` file and change the various file paths (search
    for `CHANGEME` strings in that file). The following command should do the
    trick usually.

    ```
    sed "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml > macOS.xml

    virt-xml-validate macOS.xml
    ```

  - Create a VM by running the following command.

    ```bash
    virsh --connect qemu:///system define macOS.xml
    ```

  - If needed, grant necessary permissions to libvirt-qemu user,

    ```
    sudo setfacl -m u:libvirt-qemu:rx /home/$USER
    sudo setfacl -R -m u:libvirt-qemu:rx /home/$USER/OSX-KVM
    ```

  - Launch `virt-manager` and start the `macOS` virtual machine.


* To passthrough GPUs and other devices, see [these notes](notes.md#gpu-passthrough-notes).

* Need a different resolution? Check out the [notes](notes.md#change-resolution-in-opencore) included in this repository.

* Trouble with iMessage? Check out the [notes](notes.md#trouble-with-imessage) included in this repository.

* Highly recommended macOS tweaks - https://github.com/sickcodes/osx-optimizer


For passthrough's if it's a single GPU follow Rising Prism TVs guide on it, and if not
Add the PCIE Devices(your gpu and all things in their IOMMU group except PCIE Bridges) through virt manager and boot up.

You can check the IOMMU groups by executing the following script : (credits to Risingprismtv)
'''
#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
'''
