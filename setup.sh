#!/bin/bash
clear

# Welcome
echo "This script will help set up your MacOS VM."
echo
sleep 1s

# Installing the base system
echo "First we will be choosing which version of MacOS we want."

./fetch-macOS-v2.py
qemu-img convert BaseSystem.dmg -O raw BaseSystem.img
sleep 1s

clear

# Creating the Disk
echo "In gigabytes, how big would you like your disk to be? (for the love of god make it something over 80 gigs you hog)"

read SIZE

sleep 1s

echo "Sounds good!"
sleep 2s

qemu-img create -f qcow2 mac_hdd_ng.img "$SIZE"G

clear

# Defining the VM's XML
echo "Now we will be adding the VM's XML to Virt-Manager."
sleep 1s

DIR=$(pwd)

sed -i "s|/home/CHANGEME/OSX-KVM|$DIR|g" macOS-libvirt-Catalina.xml

virt-xml-validate macOS-libvirt-Catalina.xml
virsh --connect qemu:///system define macOS-libvirt-Catalina.xml

sleep 2s

echo "The VM has been successfully configured!"
