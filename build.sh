BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

project="UART_TX"
design="src/UART_TX.v"

if [ ! -d "build" ] && [ ! -d "bin" ]; then
    mkdir "build"
    mkdir "bin"
fi

if [ $? -ne 0 ]; then
    echo "Directory Creation Failed!"
    exit 1
fi

yosys -s "synth.ys"
if [ $? -ne 0 ]; then
    echo "Synthesis Failed!"
    exit 1
fi

nextpnr-gowin --json "build/${project}.json" --freq 27 --write "build/${project}_pnr.json" --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst tangnano9k.cst
if [ $? -ne 0 ]; then
    echo "Routing Failed!"
    exit 1
fi

gowin_pack -d GW1N-9C -o "bin/${project}.fs" "build/${project}_pnr.json"
if [ $? -ne 0 ]; then
    echo "Bitstream generation Failed!"
    exit 1
fi

echo "Build Finsihed"