<div align="center">
  <h1>🛠️ x86 Assembly Memory Management Simulator</h1>
  <p>A low-level memory allocation and file system management simulator written in x86 Assembly.</p>
</div>

## 📌 Short Description
This project was developed for the Computer Systems Architecture course and simulates how an operating system allocates, retrieves, deletes, and defragments memory blocks within 1D (Array) and 2D (Matrix) memory structures.

## 💻 Tech Stack
![Assembly](https://img.shields.io/badge/Assembly-x86-blue?style=for-the-badge&logo=assembly)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![GCC](https://img.shields.io/badge/GCC-Compiler-orange?style=for-the-badge)

## ✨ Key Features
### 1. 1D Array Memory Manager (`task00-array.asm`)
| Command | Operation | Description |
| :---: | :--- | :--- |
| **1** | `ADD` | Allocates files into a continuous 1D block space based on their size (divided into 8-unit chunks). |
| **2** | `GET` | Searches and returns the memory bounds of a specific file descriptor. |
| **3** | `DELETE` | Frees up the allocated memory blocks for a specific file. |
| **4** | `DEFRAG` | Shifts all files to the left to eliminate empty gaps and optimize free space. |

### 2. 2D Matrix Memory Manager (`task01-matrix.asm`)
* **Matrix Allocation:** Extends the allocation logic to a 2D space (simulating tracks/sectors).
* **ADD (1):** Finds consecutive free blocks along matrix rows to store files.
* **GET & DELETE (2 & 3):** Two-dimensional search and memory-freeing algorithms.

## 🚀 Setup & Execution

Because this project uses 32-bit registers and links against the C standard library, you will need `gcc` with multilib support installed on a Linux environment.

**1. Clone the repository:**
```bash
git clone https://github.com/MihneaG17/Assembly-MemoryManagementComponent.git
cd Assembly-MemoryManagementComponent
```

**2. Compile the files:**
```bash
gcc -m32 -no-pie task00-array.asm -o task00
gcc -m32 -no-pie task01-matrix.asm -o task01
```

**3. Run the executables:**
```bash
./task00
./task01
```
