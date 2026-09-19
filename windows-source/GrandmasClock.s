  .equ WM_DESTROY, 2
  .equ WM_PAINT, 15
  .equ WM_ERASEBKGND, 20
  .equ WM_KEYDOWN, 256
  .equ WM_TIMER, 275

  .text
  .globl WinMainCRTStartup

WinMainCRTStartup:
  sub $104, %rsp
  xor %ecx, %ecx
  call *GetModuleHandleA_iat(%rip)
  mov %rax, hinstance(%rip)
  mov %rax, wc+24(%rip)
  xor %ecx, %ecx
  mov $32512, %edx
  call *LoadCursorA_iat(%rip)
  mov %rax, wc+40(%rip)
  lea wc(%rip), %rcx
  call *RegisterClassExA_iat(%rip)
  test %ax, %ax
  jz app_exit
  xor %ecx, %ecx
  call *GetSystemMetrics_iat(%rip)
  mov %eax, screen_w(%rip)
  mov $1, %ecx
  call *GetSystemMetrics_iat(%rip)
  mov %eax, screen_h(%rip)
  movq $0, 32(%rsp)
  movq $0, 40(%rsp)
  mov screen_w(%rip), %eax
  mov %rax, 48(%rsp)
  mov screen_h(%rip), %eax
  mov %rax, 56(%rsp)
  movq $0, 64(%rsp)
  movq $0, 72(%rsp)
  mov hinstance(%rip), %rax
  mov %rax, 80(%rsp)
  movq $0, 88(%rsp)
  mov $8, %ecx
  lea class_name(%rip), %rdx
  lea window_title(%rip), %r8
  mov $0x90000000, %r9d
  call *CreateWindowExA_iat(%rip)
  test %rax, %rax
  jz app_exit
  mov %rax, main_hwnd(%rip)
  mov %rax, %rcx
  mov $5, %edx
  call *ShowWindow_iat(%rip)
  mov main_hwnd(%rip), %rcx
  call *UpdateWindow_iat(%rip)
  mov main_hwnd(%rip), %rcx
  mov $1, %edx
  mov $1000, %r8d
  xor %r9d, %r9d
  call *SetTimer_iat(%rip)
message_loop:
  lea msg(%rip), %rcx
  xor %edx, %edx
  xor %r8d, %r8d
  xor %r9d, %r9d
  call *GetMessageA_iat(%rip)
  test %eax, %eax
  jle app_exit
  lea msg(%rip), %rcx
  call *TranslateMessage_iat(%rip)
  lea msg(%rip), %rcx
  call *DispatchMessageA_iat(%rip)
  jmp message_loop
app_exit:
  xor %ecx, %ecx
  call *ExitProcess_iat(%rip)

wndproc:
  sub $40, %rsp
  mov %rcx, wp_hwnd(%rip)
  mov %edx, wp_msg(%rip)
  mov %r8, wp_wparam(%rip)
  mov %r9, wp_lparam(%rip)
  cmp $WM_PAINT, %edx
  je do_paint
  cmp $WM_TIMER, %edx
  je do_timer
  cmp $WM_KEYDOWN, %edx
  je do_key
  cmp $WM_DESTROY, %edx
  je do_destroy
  cmp $WM_ERASEBKGND, %edx
  je erase_done
  mov wp_hwnd(%rip), %rcx
  mov wp_msg(%rip), %edx
  mov wp_wparam(%rip), %r8
  mov wp_lparam(%rip), %r9
  call *DefWindowProcA_iat(%rip)
  add $40, %rsp
  ret
do_timer:
  mov wp_hwnd(%rip), %rcx
  xor %edx, %edx
  mov $1, %r8d
  call *InvalidateRect_iat(%rip)
  xor %eax, %eax
  add $40, %rsp
  ret
do_key:
  cmpq $27, wp_wparam(%rip)
  jne key_done
  mov wp_hwnd(%rip), %rcx
  call *DestroyWindow_iat(%rip)
key_done:
  xor %eax, %eax
  add $40, %rsp
  ret
do_destroy:
  xor %ecx, %ecx
  call *PostQuitMessage_iat(%rip)
  xor %eax, %eax
  add $40, %rsp
  ret
erase_done:
  mov $1, %eax
  add $40, %rsp
  ret
do_paint:
  mov wp_hwnd(%rip), %rcx
  lea ps(%rip), %rdx
  call *BeginPaint_iat(%rip)
  mov %rax, paint_hdc(%rip)
  mov wp_hwnd(%rip), %rcx
  lea client_rect(%rip), %rdx
  call *GetClientRect_iat(%rip)
  mov $4, %ecx
  call *GetStockObject_iat(%rip)
  mov paint_hdc(%rip), %rcx
  lea client_rect(%rip), %rdx
  mov %rax, %r8
  call *FillRect_iat(%rip)
  mov paint_hdc(%rip), %rcx
  mov $1, %edx
  call *SetBkMode_iat(%rip)
  lea systime(%rip), %rcx
  call *GetLocalTime_iat(%rip)
  call prepare_text
  call prepare_rects

  mov day_ptr(%rip), %rdx
  lea rect_day(%rip), %r8
  mov client_rect+12(%rip), %eax
  neg %eax
  cdq
  mov $9, %ecx
  idiv %ecx
  mov %eax, %r9d
  movq $0xffffff, 32(%rsp)
  mov paint_hdc(%rip), %rcx
  call draw_center

  mov period_ptr(%rip), %rdx
  lea rect_period(%rip), %r8
  mov client_rect+12(%rip), %eax
  neg %eax
  cdq
  mov $16, %ecx
  idiv %ecx
  mov %eax, %r9d
  mov accent_color(%rip), %eax
  mov %rax, 32(%rsp)
  mov paint_hdc(%rip), %rcx
  call draw_center

  mov daynight_ptr(%rip), %rdx
  lea rect_daynight(%rip), %r8
  mov client_rect+12(%rip), %eax
  neg %eax
  cdq
  mov $22, %ecx
  idiv %ecx
  mov %eax, %r9d
  mov accent_color(%rip), %eax
  mov %rax, 32(%rsp)
  mov paint_hdc(%rip), %rcx
  call draw_center

  lea time_buf(%rip), %rdx
  lea rect_time(%rip), %r8
  mov client_rect+12(%rip), %eax
  neg %eax
  cdq
  mov $4, %ecx
  idiv %ecx
  mov %eax, %r9d
  movq $0xffffff, 32(%rsp)
  mov paint_hdc(%rip), %rcx
  call draw_center

  lea date_buf(%rip), %rdx
  lea rect_date(%rip), %r8
  mov client_rect+12(%rip), %eax
  neg %eax
  cdq
  mov $15, %ecx
  idiv %ecx
  mov %eax, %r9d
  movq $0xffffff, 32(%rsp)
  mov paint_hdc(%rip), %rcx
  call draw_center

  mov wp_hwnd(%rip), %rcx
  lea ps(%rip), %rdx
  call *EndPaint_iat(%rip)
  xor %eax, %eax
  add $40, %rsp
  ret

prepare_text:
  sub $40, %rsp
  movzwl systime+4(%rip), %eax
  lea day_table(%rip), %rdx
  mov (%rdx,%rax,8), %rax
  mov %rax, day_ptr(%rip)
  movzwl systime+2(%rip), %eax
  dec %eax
  lea month_table(%rip), %rdx
  mov (%rdx,%rax,8), %rax
  mov %rax, month_ptr(%rip)
  movzwl systime+8(%rip), %eax
  cmp $5, %eax
  jl is_night
  cmp $12, %eax
  jl is_morning
  cmp $18, %eax
  jl is_afternoon
  cmp $21, %eax
  jl is_evening
is_night:
  lea str_night(%rip), %rax
  mov %rax, period_ptr(%rip)
  lea str_nighttime(%rip), %rax
  mov %rax, daynight_ptr(%rip)
  movl $0xffc78f, accent_color(%rip)
  jmp format_text
is_morning:
  lea str_morning(%rip), %rax
  mov %rax, period_ptr(%rip)
  lea str_daytime(%rip), %rax
  mov %rax, daynight_ptr(%rip)
  movl $0x5cd1ff, accent_color(%rip)
  jmp format_text
is_afternoon:
  lea str_afternoon(%rip), %rax
  mov %rax, period_ptr(%rip)
  lea str_daytime(%rip), %rax
  mov %rax, daynight_ptr(%rip)
  movl $0x5cd1ff, accent_color(%rip)
  jmp format_text
is_evening:
  lea str_evening(%rip), %rax
  mov %rax, period_ptr(%rip)
  lea str_nighttime(%rip), %rax
  mov %rax, daynight_ptr(%rip)
  movl $0xffc78f, accent_color(%rip)
format_text:
  movzwl systime+8(%rip), %eax
  mov %eax, %r8d
  cmp $12, %eax
  jae pm_time
  lea str_am(%rip), %rax
  mov %rax, ampm_ptr(%rip)
  test %r8d, %r8d
  jne hour_ready
  mov $12, %r8d
  jmp hour_ready
pm_time:
  lea str_pm(%rip), %rax
  mov %rax, ampm_ptr(%rip)
  cmp $12, %r8d
  je hour_ready
  sub $12, %r8d
hour_ready:
  movzwl systime+10(%rip), %r9d
  mov ampm_ptr(%rip), %rax
  mov %rax, 32(%rsp)
  lea time_buf(%rip), %rcx
  lea fmt_time(%rip), %rdx
  call *wsprintfA_iat(%rip)
  mov month_ptr(%rip), %r8
  movzwl systime+6(%rip), %r9d
  movzwl systime(%rip), %eax
  mov %rax, 32(%rsp)
  lea date_buf(%rip), %rcx
  lea fmt_date(%rip), %rdx
  call *wsprintfA_iat(%rip)
  add $40, %rsp
  ret

prepare_rects:
  mov client_rect+8(%rip), %eax
  mov %eax, rect_day+8(%rip)
  mov %eax, rect_period+8(%rip)
  mov %eax, rect_daynight+8(%rip)
  mov %eax, rect_time+8(%rip)
  mov %eax, rect_date+8(%rip)
  mov client_rect+12(%rip), %eax
  mov %eax, %edx
  imul $18, %eax, %eax
  cdq
  mov $100, %ecx
  idiv %ecx
  mov %eax, rect_day+12(%rip)
  mov %eax, rect_period+4(%rip)
  mov client_rect+12(%rip), %eax
  imul $30, %eax, %eax
  cdq
  mov $100, %ecx
  idiv %ecx
  mov %eax, rect_period+12(%rip)
  mov %eax, rect_daynight+4(%rip)
  mov client_rect+12(%rip), %eax
  imul $40, %eax, %eax
  cdq
  mov $100, %ecx
  idiv %ecx
  mov %eax, rect_daynight+12(%rip)
  mov %eax, rect_time+4(%rip)
  mov client_rect+12(%rip), %eax
  imul $75, %eax, %eax
  cdq
  mov $100, %ecx
  idiv %ecx
  mov %eax, rect_time+12(%rip)
  mov %eax, rect_date+4(%rip)
  mov client_rect+12(%rip), %eax
  mov %eax, rect_date+12(%rip)
  ret

draw_center:
  mov %rcx, draw_hdc(%rip)
  mov %rdx, draw_text(%rip)
  mov %r8, draw_rect(%rip)
  mov %r9d, draw_size(%rip)
  mov 40(%rsp), %rax
  mov %eax, draw_color(%rip)
  sub $120, %rsp
  movq $900, 32(%rsp)
  movq $0, 40(%rsp)
  movq $0, 48(%rsp)
  movq $0, 56(%rsp)
  movq $1, 64(%rsp)
  movq $0, 72(%rsp)
  movq $0, 80(%rsp)
  movq $5, 88(%rsp)
  movq $0, 96(%rsp)
  lea font_name(%rip), %rax
  mov %rax, 104(%rsp)
  mov draw_size(%rip), %ecx
  xor %edx, %edx
  xor %r8d, %r8d
  xor %r9d, %r9d
  call *CreateFontA_iat(%rip)
  mov %rax, draw_font(%rip)
  mov draw_hdc(%rip), %rcx
  mov %rax, %rdx
  call *SelectObject_iat(%rip)
  mov %rax, old_font(%rip)
  mov draw_hdc(%rip), %rcx
  mov draw_color(%rip), %edx
  call *SetTextColor_iat(%rip)
  movq $0x25, 32(%rsp)
  mov draw_hdc(%rip), %rcx
  mov draw_text(%rip), %rdx
  mov $-1, %r8d
  mov draw_rect(%rip), %r9
  call *DrawTextA_iat(%rip)
  mov draw_hdc(%rip), %rcx
  mov old_font(%rip), %rdx
  call *SelectObject_iat(%rip)
  mov draw_font(%rip), %rcx
  call *DeleteObject_iat(%rip)
  add $120, %rsp
  ret

  .data
  .p2align 3
wc:
  .long 80, 3
  .quad wndproc
  .long 0, 0
  .quad 0, 0, 0, 6, 0, class_name, 0
hinstance: .quad 0
main_hwnd: .quad 0
screen_w: .long 0
screen_h: .long 0
wp_hwnd: .quad 0
wp_msg: .long 0
  .long 0
wp_wparam: .quad 0
wp_lparam: .quad 0
paint_hdc: .quad 0
day_ptr: .quad 0
month_ptr: .quad 0
period_ptr: .quad 0
daynight_ptr: .quad 0
ampm_ptr: .quad 0
accent_color: .long 0
draw_hdc: .quad 0
draw_text: .quad 0
draw_rect: .quad 0
draw_size: .long 0
draw_color: .long 0
draw_font: .quad 0
old_font: .quad 0

  .section .rdata,"a",@progbits
class_name: .asciz "GrandmasDayNightClock"
window_title: .asciz "Grandma's Day & Night Clock"
font_name: .asciz "Arial"
fmt_time: .asciz "%d:%02d %s"
fmt_date: .asciz "%s %d, %d"
str_am: .asciz "A.M."
str_pm: .asciz "P.M."
str_morning: .asciz "MORNING"
str_afternoon: .asciz "AFTERNOON"
str_evening: .asciz "EVENING"
str_night: .asciz "NIGHT"
str_daytime: .asciz "IT IS DAYTIME"
str_nighttime: .asciz "IT IS NIGHTTIME"
d_sun: .asciz "SUNDAY"
d_mon: .asciz "MONDAY"
d_tue: .asciz "TUESDAY"
d_wed: .asciz "WEDNESDAY"
d_thu: .asciz "THURSDAY"
d_fri: .asciz "FRIDAY"
d_sat: .asciz "SATURDAY"
day_table: .quad d_sun,d_mon,d_tue,d_wed,d_thu,d_fri,d_sat
m_jan: .asciz "JANUARY"
m_feb: .asciz "FEBRUARY"
m_mar: .asciz "MARCH"
m_apr: .asciz "APRIL"
m_may: .asciz "MAY"
m_jun: .asciz "JUNE"
m_jul: .asciz "JULY"
m_aug: .asciz "AUGUST"
m_sep: .asciz "SEPTEMBER"
m_oct: .asciz "OCTOBER"
m_nov: .asciz "NOVEMBER"
m_dec: .asciz "DECEMBER"
month_table: .quad m_jan,m_feb,m_mar,m_apr,m_may,m_jun,m_jul,m_aug,m_sep,m_oct,m_nov,m_dec

  .bss
  .p2align 3
msg: .skip 48
ps: .skip 72
client_rect: .skip 16
rect_day: .skip 16
rect_period: .skip 16
rect_daynight: .skip 16
rect_time: .skip 16
rect_date: .skip 16
systime: .skip 16
time_buf: .skip 64
date_buf: .skip 128

  .section .idata$2,"aw",@progbits
  .long kernel_ilt-0x400000,0,0,kernel_name-0x400000,kernel_iat-0x400000
  .long user_ilt-0x400000,0,0,user_name-0x400000,user_iat-0x400000
  .long gdi_ilt-0x400000,0,0,gdi_name-0x400000,gdi_iat-0x400000

  .section .idata$4,"aw",@progbits
kernel_ilt: .quad hn_GetModuleHandleA-0x400000,hn_GetLocalTime-0x400000,hn_ExitProcess-0x400000,0
user_ilt: .quad hn_RegisterClassExA-0x400000,hn_LoadCursorA-0x400000,hn_CreateWindowExA-0x400000,hn_ShowWindow-0x400000,hn_UpdateWindow-0x400000,hn_GetMessageA-0x400000,hn_TranslateMessage-0x400000,hn_DispatchMessageA-0x400000,hn_DefWindowProcA-0x400000,hn_PostQuitMessage-0x400000,hn_SetTimer-0x400000,hn_InvalidateRect-0x400000,hn_BeginPaint-0x400000,hn_EndPaint-0x400000,hn_GetClientRect-0x400000,hn_FillRect-0x400000,hn_DestroyWindow-0x400000,hn_wsprintfA-0x400000,hn_GetSystemMetrics-0x400000,hn_DrawTextA-0x400000,0
gdi_ilt: .quad hn_GetStockObject-0x400000,hn_CreateFontA-0x400000,hn_SelectObject-0x400000,hn_SetTextColor-0x400000,hn_SetBkMode-0x400000,hn_DeleteObject-0x400000,0

  .section .idata$5,"aw",@progbits
kernel_iat:
GetModuleHandleA_iat: .quad hn_GetModuleHandleA-0x400000
GetLocalTime_iat: .quad hn_GetLocalTime-0x400000
ExitProcess_iat: .quad hn_ExitProcess-0x400000
  .quad 0
user_iat:
RegisterClassExA_iat: .quad hn_RegisterClassExA-0x400000
LoadCursorA_iat: .quad hn_LoadCursorA-0x400000
CreateWindowExA_iat: .quad hn_CreateWindowExA-0x400000
ShowWindow_iat: .quad hn_ShowWindow-0x400000
UpdateWindow_iat: .quad hn_UpdateWindow-0x400000
GetMessageA_iat: .quad hn_GetMessageA-0x400000
TranslateMessage_iat: .quad hn_TranslateMessage-0x400000
DispatchMessageA_iat: .quad hn_DispatchMessageA-0x400000
DefWindowProcA_iat: .quad hn_DefWindowProcA-0x400000
PostQuitMessage_iat: .quad hn_PostQuitMessage-0x400000
SetTimer_iat: .quad hn_SetTimer-0x400000
InvalidateRect_iat: .quad hn_InvalidateRect-0x400000
BeginPaint_iat: .quad hn_BeginPaint-0x400000
EndPaint_iat: .quad hn_EndPaint-0x400000
GetClientRect_iat: .quad hn_GetClientRect-0x400000
FillRect_iat: .quad hn_FillRect-0x400000
DestroyWindow_iat: .quad hn_DestroyWindow-0x400000
wsprintfA_iat: .quad hn_wsprintfA-0x400000
GetSystemMetrics_iat: .quad hn_GetSystemMetrics-0x400000
DrawTextA_iat: .quad hn_DrawTextA-0x400000
  .quad 0
gdi_iat:
GetStockObject_iat: .quad hn_GetStockObject-0x400000
CreateFontA_iat: .quad hn_CreateFontA-0x400000
SelectObject_iat: .quad hn_SelectObject-0x400000
SetTextColor_iat: .quad hn_SetTextColor-0x400000
SetBkMode_iat: .quad hn_SetBkMode-0x400000
DeleteObject_iat: .quad hn_DeleteObject-0x400000
  .quad 0

  .section .idata$6,"aw",@progbits
kernel_name: .asciz "KERNEL32.dll"
user_name: .asciz "USER32.dll"
gdi_name: .asciz "GDI32.dll"

  .section .idata$7,"aw",@progbits
  .p2align 1
.macro HN label, name
\label: .short 0; .asciz "\name"; .p2align 1
.endm
HN hn_GetModuleHandleA, GetModuleHandleA
HN hn_GetLocalTime, GetLocalTime
HN hn_ExitProcess, ExitProcess
HN hn_RegisterClassExA, RegisterClassExA
HN hn_LoadCursorA, LoadCursorA
HN hn_CreateWindowExA, CreateWindowExA
HN hn_ShowWindow, ShowWindow
HN hn_UpdateWindow, UpdateWindow
HN hn_GetMessageA, GetMessageA
HN hn_TranslateMessage, TranslateMessage
HN hn_DispatchMessageA, DispatchMessageA
HN hn_DefWindowProcA, DefWindowProcA
HN hn_PostQuitMessage, PostQuitMessage
HN hn_SetTimer, SetTimer
HN hn_InvalidateRect, InvalidateRect
HN hn_BeginPaint, BeginPaint
HN hn_EndPaint, EndPaint
HN hn_GetClientRect, GetClientRect
HN hn_FillRect, FillRect
HN hn_DestroyWindow, DestroyWindow
HN hn_wsprintfA, wsprintfA
HN hn_GetSystemMetrics, GetSystemMetrics
HN hn_DrawTextA, DrawTextA
HN hn_GetStockObject, GetStockObject
HN hn_CreateFontA, CreateFontA
HN hn_SelectObject, SelectObject
HN hn_SetTextColor, SetTextColor
HN hn_SetBkMode, SetBkMode
HN hn_DeleteObject, DeleteObject
