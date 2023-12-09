#include <stdio.h>
#include <ulib.h>
#include "unistd.h"
#define FILE_SIZE 4096
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PAGES 1024
#define PAGE_SIZE 4096
#define MADV_DONTNEED 1024
#define MAX_MAPPINGS 1024
typedef struct {
    char *fileContent; // 指向文件内容的指针
    bool used;         // 是否已经被映射
} MemoryMapping;

MemoryMapping mappings[MAX_MAPPINGS];
char simulated_file[FILE_SIZE]; // 模拟文件映射到的内存区域

// 初始化模拟的内存映射
void initializeMappings() {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        mappings[i].fileContent = NULL;
        mappings[i].used = 0;
    }
    // 初始化模拟文件的内容
    memset(simulated_file, 0, FILE_SIZE);
}

// 模拟 mmap 系统调用
void *simulate_mmap(void) {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        if (!mappings[i].used) {
            mappings[i].used = 1;
            mappings[i].fileContent = simulated_file;
            printf("Memory mapped at index %d\n", i);
            return (void *)mappings[i].fileContent;
        }
    }
    printf("Error: No available memory for mapping\n");
    return NULL;
}

// 模拟 munmap 系统调用
int simulate_munmap(void *addr) {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        if (mappings[i].fileContent == addr && mappings[i].used) {
            mappings[i].used = 0;
            printf("Memory unmapped at index %d\n", i);
            return 0; // Success
        }
    }
    printf("Error: Memory not found for unmapping\n");
    return -1; // Failure
}

// 打印当前内存映射状态
void printMappingStatus() {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        printf("Mapping %d: %s\n", i, mappings[i].used ? "Used" : "Free");
    }
}

// 模拟 madvise 行为
void simulateMadvise(void *page, int advice) {
    printf("Simulating madvise\n");

    switch (advice) {
        case MADV_DONTNEED:
            // 释放指定的页面
            freePage(page);
            printf("Page freed\n");
            break;
        default:
            printf("Unsupported advice type\n");
    }

    // 记录内存池状态
    for (int i = 0; i < MAX_PAGES; i++) {
        printf("Page %d: %s\n", i, mappings[i].used ? "In Use" : "Free");
    }
}


volatile int stop_threads = 0;
char simulated_file[FILE_SIZE]; // 模拟文件映射到的内存区域


// 模拟写线程
void *write_thread_func(void *arg) {
    char *addr = (char *)arg;
    while (!stop_threads) {
        for (int i = 0; i < 10; i++) {
            addr[i] = 'A'; // 模拟向映射内存写入数据
        }
        sleep(200); // 休眠以模拟写入延迟
    }
    printf("Write thread exiting\n");
    return NULL;
}

// 模拟 madvise 线程
void *madvise_thread_func(void *arg) {
    while (!stop_threads) {
        simulateMadvise(arg,MADV_DONTNEED); // 模拟 madvise 调用
        sleep(20); // 休眠以模拟调用间隔
    }
    printf("Madvise thread exiting\n");
    return NULL;
}

int main0() {
    // 模拟 mmap 过程
    void *mapped_memory = simulate_mmap();

    int pid = fork();
    if (pid == 0) {
        write_thread_func(mapped_memory);
        exit(0);
    }

    int pid2 = fork();
    if (pid2 == 0) {
        madvise_thread_func(mapped_memory);
        exit(0);
    }

    getchar(); // 等待用户输入来停止子进程
    stop_threads = 1;

    waitpid(pid, 0);
    waitpid(pid2, 0);
    
    printf("Main process exiting\n");
    return 0;
}
void print_file(){
    printf("%s\n",simulated_file);
    printf("end of file\n",simulated_file);
}

int
main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());
    cprintf("hello pass.\n");
    return 0;
}

