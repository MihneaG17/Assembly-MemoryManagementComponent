.data
    matrix: .space 4194304           
    dimensiune_matrice: .long 1024  
    lines: .long 8
    columns: .long 8

    columnIndex: .long 0         
    lineIndex: .long 0          
    index: .long 0
    ecx_copy: .long 0
    eax_copy: .long 0
    edx_copy: .long 0

    nr_operatii: .long 0        
    contor_nr_op: .long 0
    operatie: .long 0
    add: .long 1
    get: .long 2
    delete: .long 3
    defragmentation: .long 4

    cate_fisiere: .long 0
    nr_fisier: .long 0
    dimensiune_fisier: .long 0
    nr_blocuri: .long 0
    contor_spatiu_liber: .long 0  
    spatiu_gasit: .long 0 
    start_x: .long 0
    start_y: .long 0
    end_x: .long 0
    end_y: .long 0
    impartire_opt: .long 8
    descriptor: .long 0
    get_inceput_linie: .long 0
    get_inceput_col: .long 0
    get_final_linie: .long 0
    get_final_col: .long 0
    ok_del: .long 0
    descriptor_curent: .long 0
    block_inceput: .long 0

    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d "
    formatNewLine: .asciz "\n"
    formatAfisAdd: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatAfisAddNotFound: .asciz "%d: ((0, 0), (0, 0))\n"
    formatAfisGet: .asciz "((%d, %d), (%d, %d))\n"
    formatGetNotFound: .asciz "((0, 0), (0, 0))\n"
    newLine: .asciz "\n"
    formatMatrix: .asciz "%d "
    formatTest: .asciz "Salut!\n"
.text
.global main

main:
    #initializare matrice cu 0 (memoria este stocata liniar deci o pot initializa in aceeasi maniera ca in cazul unidimensional)
    lea matrix,%edi
    
    movl $0,%ecx           
    movl $1048576,%ebx          

    init_matrix:
    movl $0,(%edi,%ecx,4)  
    incl %ecx
    cmpl %ebx,%ecx
    jl init_matrix         
    
    movl $0,lineIndex
    movl $0,contor_nr_op

    pushl $nr_operatii
    push $formatScanf
    call scanf
    addl $8,%esp

operatii:
    movl nr_operatii,%eax
    cmpl contor_nr_op,%eax
    je et_exit
    incl contor_nr_op 

    pushl $operatie
    push $formatScanf
    call scanf
    addl $8,%esp

    movl operatie,%ebx
    cmpl add,%ebx        
    je et_add
    
    movl operatie,%ebx
    cmpl get,%ebx        
    je et_get

    movl operatie,%ebx
    cmpl delete,%ebx        
    je et_delete

    movl operatie,%ebx
    cmpl defragmentation,%ebx        
    je et_defragmentation

et_add:
    pushl $cate_fisiere
    push $formatScanf
    call scanf
    addl $8,%esp

    movl $0,ecx_copy     

add_for_nr_fisiere:
    
    movl ecx_copy,%ecx
    cmpl cate_fisiere,%ecx
    je add_exit          

    pushl $nr_fisier
    push $formatScanf
    call scanf
    addl $8,%esp

    pushl $dimensiune_fisier
    push $formatScanf
    call scanf
    addl $8,%esp

    movl dimensiune_fisier,%eax
    xorl %edx,%edx
    divl impartire_opt
    cmpl $0,%edx
    je skip_aproximare
    incl %eax

skip_aproximare:
    movl %eax,nr_blocuri

    #incepe cautarea pe linii in matrice

    movl $0,lineIndex
    movl $0,columnIndex
    movl $0,contor_spatiu_liber

cauta_spatiu:
    
    movl lineIndex,%ecx
    cmpl dimensiune_matrice,%ecx
    je et_afisare_add_not_found

    
    movl columnIndex,%ecx
    cmpl dimensiune_matrice,%ecx
    je next_line

    # calculez poziția în matrice
    movl lineIndex,%eax
    mull dimensiune_matrice
    addl columnIndex,%eax

    # verific daca poz curenta e libera
    movl (%edi,%eax,4),%ebx
    cmpl $0,%ebx
    jne reset_spatiu

    # am gasit spatiu liber
    incl contor_spatiu_liber
    movl contor_spatiu_liber,%ecx
    cmpl nr_blocuri,%ecx
    je et_update_add

    incl columnIndex
    jmp cauta_spatiu

reset_spatiu:
    movl $0,contor_spatiu_liber
    incl columnIndex
    jmp cauta_spatiu

next_line:
    incl lineIndex
    movl $0,columnIndex
    movl $0,contor_spatiu_liber
    jmp cauta_spatiu

et_update_add:
    
    movl lineIndex,%eax
    movl %eax,start_x

    movl columnIndex,%ecx
    subl nr_blocuri,%ecx
    addl $1,%ecx
    movl %ecx,start_y

    movl lineIndex,%eax
    movl %eax,end_x

    movl columnIndex,%eax
    movl %eax,end_y

    #actualizez matricea
    movl start_x,%eax
    movl start_y,%ecx

update_matrix:
    pushl %eax
    mull dimensiune_matrice
    addl %ecx,%eax
    movl nr_fisier,%ebx
    movl %ebx,(%edi,%eax,4)
    popl %eax

    incl %ecx
    cmpl end_y,%ecx
    jle update_matrix

    jmp afisare_add

afisare_add:
    
    pushl end_y
    pushl end_x
    pushl start_y
    pushl start_x
    pushl nr_fisier
    push $formatAfisAdd
    call printf
    addl $24,%esp

    pushl $0
    call fflush
    addl $4,%esp

    incl ecx_copy           
    jmp add_for_nr_fisiere

et_afisare_add_not_found:
    pushl nr_fisier
    push $formatAfisAddNotFound
    call printf
    addl $8,%esp
    
    pushl $0
    call fflush
    addl $4,%esp

    incl ecx_copy           
    jmp add_for_nr_fisiere

add_exit:     
    jmp operatii

et_get:
    pushl $descriptor
    push $formatScanf
    call scanf
    addl $8,%esp

    xorl %ecx,%ecx
    lea matrix,%edi

    movl $0,get_inceput_col
    decl get_inceput_col
    movl $0,get_inceput_linie
    movl $0, get_final_col
    movl $0, get_final_linie

    movl $0,lineIndex
    movl $0,columnIndex

    #incepe for-ul de parcurgere a liniilor

    for_get_linie:
        movl lineIndex,%ecx
        cmpl dimensiune_matrice,%ecx
        je et_get_not_found

        movl $0,get_inceput_col
        decl get_inceput_col


        #incepe for-ul de parcurgere a coloanelor

            for_get_col:
                movl columnIndex,%ecx
                cmpl dimensiune_matrice,%ecx
                je et_next_line_get

                movl descriptor,%ebx

                # calculez poziția în matrice
                movl lineIndex,%eax
                mull dimensiune_matrice
                addl columnIndex,%eax

                movl (%edi,%eax,4),%edx

                cmpl %ebx,%edx
                je et_descriptor_gasit_get

            verificare_get_finalizat:

                incl columnIndex
                jmp for_get_col

        
    et_next_line_get:

        movl get_inceput_col,%eax
        cmpl $-1,%eax
        jne et_get_found


        incl lineIndex
        movl $0,columnIndex
        jmp for_get_linie

et_descriptor_gasit_get:
    movl get_inceput_col,%ebx
    cmpl $-1,%ebx
    je actualizare_indici_get

    indice_actualizat_get: #eticheta de revenire 

    movl columnIndex,%ebp
    movl %ebp,get_final_col

    movl lineIndex,%ebp
    movl %ebp,get_inceput_linie
    movl %ebp,get_final_linie

    jmp verificare_get_finalizat


actualizare_indici_get:
    movl columnIndex,%ebp
    movl %ebp,get_inceput_col
    jmp indice_actualizat_get

et_get_found:
    pushl get_final_col
    pushl get_final_linie
    pushl get_inceput_col
    pushl get_inceput_linie
    push $formatAfisGet
    call printf
    addl $20,%esp

    pushl $0
    call fflush
    addl $4,%esp

    jmp operatii

et_get_not_found:

    push $formatGetNotFound
    call printf
    addl $4,%esp

    pushl $0
    call fflush
    addl $4,%esp

    jmp operatii


et_delete:
    pushl $descriptor
    push $formatScanf
    call scanf
    addl $8,%esp

    movl $0,ok_del

    xorl %ecx,%ecx
    lea matrix,%edi

    movl $0,lineIndex
    movl $0,columnIndex

    #incepe for-ul de parcurgere a liniilor

    for_delete_linie:

    movl lineIndex,%ecx
    cmpl dimensiune_matrice,%ecx
    je afisare_del

    movl ok_del,%ebx
    cmpl $1,%ebx
    je afisare_del

    #incepe for-ul de parcurgere a coloanelor

        for_delete_col:

        movl columnIndex,%ecx
        cmpl %ecx,dimensiune_matrice
        je next_line_del

        # calculez pozitia în matrice
        movl lineIndex,%eax
        mull dimensiune_matrice
        addl columnIndex,%eax

        movl (%edi,%eax,4),%edx

        cmpl descriptor,%edx
        je delete_update

        cont_for_del:
        incl columnIndex
        jmp for_delete_col

    next_line_del:

        incl lineIndex
        movl $0,columnIndex
        jmp for_delete_linie


delete_update:
    movl $0,%ebx
    movl %ebx,(%edi,%eax,4)
    movl $1,ok_del
    jmp cont_for_del


afisare_del:

    movl $0,descriptor_curent

    xorl %ecx,%ecx
    lea matrix,%edi

    movl $0,lineIndex
    movl $0,columnIndex

#incepe for-ul de parcurgere a liniilor

for_afisare_del_linie:
    movl lineIndex,%ecx
    cmpl dimensiune_matrice,%ecx
    je delete_exit

    movl $-1,block_inceput
    movl $0,columnIndex 

    #incepe for-ul de parcurgere al coloanelor

    for_afisare_del_col:
        movl columnIndex,%ecx
        cmpl dimensiune_matrice,%ecx
        je verifica_sfarsit_linie  

        # calculez pozitia curenta in matrice
        movl lineIndex,%eax
        mull dimensiune_matrice
        addl columnIndex,%eax
    
    movl (%edi,%eax,4),%ebx  
    
    cmpl $0,%ebx
    je element_zero
    
    # element nenul găsit
    movl block_inceput,%edx
    cmpl $-1,%edx
    je primul_element_nenul
    
    cmpl descriptor_curent,%ebx
    jne schimbare_descriptor

continua_for:
    incl columnIndex
    jmp for_afisare_del_col

element_zero:
    movl block_inceput,%edx
    cmpl $-1,%edx
    jne afiseaza_bloc
    jmp continua_for

primul_element_nenul:
    movl columnIndex,%edx
    movl %edx,block_inceput
    movl %ebx,descriptor_curent
    jmp continua_for

schimbare_descriptor:

    movl columnIndex,%edx
    decl %edx
    pushl %edx            
    pushl lineIndex       
    pushl block_inceput   
    pushl lineIndex       
    pushl descriptor_curent 
    push $formatAfisAdd
    call printf
    addl $24,%esp
    
    movl columnIndex,%edx
    movl %edx,block_inceput
    movl %ebx,descriptor_curent
    incl columnIndex
    jmp for_afisare_del_col

afiseaza_bloc:

    movl columnIndex,%edx
    decl %edx
    pushl %edx            
    pushl lineIndex      
    pushl block_inceput  
    pushl lineIndex       
    pushl descriptor_curent 
    push $formatAfisAdd
    call printf
    addl $24,%esp
    
    movl $-1,block_inceput
    incl columnIndex
    jmp for_afisare_del_col

verifica_sfarsit_linie:

    movl block_inceput,%edx
    cmpl $-1,%edx
    je next_line_afis_del
    
    movl dimensiune_matrice,%edx
    decl %edx
    pushl %edx            
    pushl lineIndex       
    pushl block_inceput   
    pushl lineIndex       
    pushl descriptor_curent 
    push $formatAfisAdd
    call printf
    addl $24,%esp

next_line_afis_del:
    incl lineIndex
    jmp for_afisare_del_linie

delete_exit:
    jmp operatii

et_defragmentation:
    jmp operatii


et_exit: 
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    xorl %ebx,%ebx
    int $0x80