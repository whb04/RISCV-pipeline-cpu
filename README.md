## RV-32I 流水线CPU

#### 实验内容

> USTC 2023 COD Lab6

实现一个流水线CPU，使其支持所有非系统 RV32-I 指令

#### 逻辑设计

##### CPU的所有模块:

**[IF]** `inst_mem`, `pc`, `inst_flush`, `adder1`

**[ID]** `ctrl`, `rf`, `immediate`, `adder2`

**[EX]** `rf_rd0_fwd`, `rf_rd1_fwd`, `alu_sel1`, `alu_sel2`, `alu`, `branch`, `pc_sel_gen`, `ander`, `npc_sel`

**[MEM]** `data_mem`

**[WB]** `reg_write_sel`

**冒险处理** `hazard`

**段间寄存器** `seg_reg_if_id`, `seg_reg_id_ex`, `seg_reg_ex_mem`, `seg_reg_mem_wb`

**调试** `check_data_sel_if`, `check_data_sel_id`, `check_data_sel_ex`, `check_data_sel_mem`, `check_data_sel_wb`, `check_data_sel_hzd`, `check_data_seg_sel`, `cpu_check_data_sel`



**inst_mem**

指令存储器

**pc**

PC寄存器，输入下一个PC值，输出当前PC值

**inst_flush**

选择器，输入指令存储器中读取的指令，输出这个指令或是 `0x00000033` (用作`nop`) 

**adder1**

输入PC，输出PC+4

**ctrl**

控制模块，输入指令，输出一系列控制信号

**rf**

寄存器堆，写优先，`x0` 恒为0

**immediate**

输入指令和立即数类型，输出立即数（立即数类型可以由指令判断，但为了简化代码交给控制模块处理）

**adder2**

输入PC和立即数imm，输出PC+imm，用作 `jal` 跳转的目标

**rf_rd*_fwd**

选择器，决定EX段使用的寄存器值是否前递

**alu_sel1**

选择器，决定ALU的操作数1来自寄存器还是PC

**alu_sel2**

选择器，决定ALU的操作数2来自寄存器还是立即数

**alu**

算术逻辑单元

**branch**

决定B型指令是否跳转

**pc_sel_gen**

输入跳转使能 `jal_id, jalr_ex, br_ex` ，决定跳转类型

如果 `jal_id` 和另一个使能同时为1，说明是 B/jalr 指令后紧跟着 jal，此时执行前者。B/jalr 指令会在EX段跳转，jal指令会在ID段跳转。

**ander**

输入ALU的计算结果，将其按2Byte对齐（兼容16位指令）后输出，作为jalr的跳转目标

**npc_sel**

选择器，输出下一个PC的值，可能为 `pc_add4_if, pc_jalr_ex, alu_ans_ex, pc_jal_id`

**reg_write_sel**

选择器，输出要写入寄存器的值，可能为 `alu_ans_wb, pc_add4_wb, dm_dout_wb, imm_wb`

**seg_reg_* **

段间寄存器，接收 flush 和 stall 信号，分别表示将寄存器同步复位和输出保持不变

**hazard**

冒险处理模块，输入为需要的信号，输出为各段间寄存器的 flush 和 stall 信号

- 控制冒险
  - jal在ID段检测，冲刷IF/ID寄存器
  - jalr和B-type在EX段检测，冲刷IF/ID和ID/EX寄存器
- 数据冒险
  - Load-Use型冒险在ID段检测，停顿PC和IF/ID寄存器，冲刷EX寄存器
  - 对寄存器0和1，分别依次检测以下两种冒险
  - 检测由于写寄存器指令还在MEM段引起的冒险，前递EX/MEM寄存器中的数据
  - 否则检测由于写寄存器指令还在WB段引起的冒险，前递MEM/WB寄存器中的数据

##### MEM的所有模块

**inst_mem**

指令存储器，例化一个512*32的ROM来实现。输入`im_addr[10:2]`，输出`im_dout`。

**data_mem***

数据存储器，例化四个256*8的DPRAM来实现。顶层模块 `MEM` 输入 `dm_addr`, `dm_we`, `dm_type`, `dm_din`, 输出 `dm_dout`

`dm_type` 信号有3位，低2位值为 0,1,2 分别对应读/写内存模式为 byte,halfbyte,word，高1位值为 0,1 分别对应读数据有符号和无符号扩展。

存储器 x 的模块调用（略去调试端口）：

```verilog
DPRAM data_memx(
    .clk        (clk),
    .we         (dm_we & dm_we_mask[x]),
    .a          (dm_addr[9:2]),
    .d          (dm_din_byte[x & dm_wa_mask]),
    .spo        (dm_dout_byte[x])
);
```

- 读
  - 定义8位信号 `dm_dout_byte[3:0]`
  - 存储器 x 读到 `dm_dout_byte[x]` 中
  - 根据 `dm_type, dm_addr[1:0]` 拼接和扩展 `dm_dout_byte` 来得到 `dm_dout`
- 写
  - 定义4位信号 `dm_we_mask`，2位信号 `dm_wa_mask`
  - 定义8位信号 `dm_din_byte[3:0]`
  - `dm_we_mask[x]` 表示存储器 x 是否会被访问
  - `dm_wa_mask&x` 表示要写入存储器 x 的字节在 `dm_din` 中的地址
  - `dm_din_byte[x]` 表示 `dm_din` 的第 x 个字节
  - 根据 `dm_type[1:0]` 来得到 `dm_we_mask` 和 `dm_wa_mask`
