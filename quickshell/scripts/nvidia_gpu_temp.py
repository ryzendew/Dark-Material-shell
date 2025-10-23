#!/usr/bin/env python3
import pynvml
import json
import sys

def get_gpu_temp():
    gpus = []
    try:
        pynvml.nvmlInit()
        device_count = pynvml.nvmlDeviceGetCount()
        for i in range(device_count):
            handle = pynvml.nvmlDeviceGetHandleByIndex(i)
            name_bytes = pynvml.nvmlDeviceGetName(handle)
            name = name_bytes.decode('utf-8') if isinstance(name_bytes, bytes) else str(name_bytes)
            temperature = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
            memory_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
            pci_info = pynvml.nvmlDeviceGetPciInfo(handle)
            bus_id = pci_info.busId
            pci_id = bus_id.decode('utf-8') if isinstance(bus_id, bytes) else str(bus_id)
            gpus.append({
                "index": i,
                "name": name,
                "displayName": name,
                "fullName": name,
                "pciId": pci_id,
                "temperature": temperature,
                "memoryUsed": memory_info.used,
                "memoryTotal": memory_info.total,
                "memoryUsedMB": memory_info.used // (1024 * 1024),
                "memoryTotalMB": memory_info.total // (1024 * 1024),
                "vendor": "NVIDIA",
                "driver": "nvidia"
            })
    except pynvml.NVMLError as error:
        print(json.dumps({"error": str(error)}), file=sys.stderr)
    finally:
        try:
            pynvml.nvmlShutdown()
        except pynvml.NVMLError:
            pass
    return {"gpus": gpus}

if __name__ == "__main__":
    print(json.dumps(get_gpu_temp()))