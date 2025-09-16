.data
    v: .space 4096
    dimensiune_vector: .long 1024
    nr_operatii: .space 4
    contor_nr_op: .long 0
    operatie: .space 4
    nr_fisier: .space 4
    dimensiune_fisier: .space 4
    cate_fisiere: .space 4
    nr_blocuri: .space 4
    impartire_opt: .long 8
    contor_add: .long 0
    ok_add: .long 0
    block_inceput: .long 0
    opreste_for: .long 0
    capat_interval: .long 0
    descriptor_get: .long 0
    get_inceput: .long 0
    get_final: .long 0
    descriptor_delete: .long 0
    descriptor_curent: .long 0
    index_frag: .long 0
    aux_swap: .long 0
    ecx_copy: .long 0
    eax_copy: .long 0
    edx_copy: .long 0
    add: .long 1
    get: .long 2
    delete: .long 3
    defragmentation: .long 4
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d\n"
    formatAfisAdd: .asciz "%d: (%d, %d)\n"
    formatAfisAddNotFound: .asciz "%d: (0, 0)\n"
    formatArray: .asciz "%d "
    formatGetFound: .asciz "(%d, %d)\n"
    formatGetNotFound: .asciz "(0, 0)\n"
.text
.global main

#initializare vector cu 0
main:
    lea v,%edi
    xorl %ecx,%ecx
initializare_loop:
    movl dimensiune_vector,%eax
    cmpl %ecx,%eax
    je citire_nroperatii
    movl $0,(%edi,%ecx,4)
    incl %ecx
    jmp initializare_loop


#citire numar de operatii ce vor fi efectuate
citire_nroperatii:
    pushl $nr_operatii
    push $formatScanf
    call scanf 
    addl $8,%esp

    #for care efectueaza numarul de operatii dat

operatii:
    movl nr_operatii,%eax
    cmpl contor_nr_op,%eax
    je et_exit
    incl contor_nr_op

    #citesc operatia
    pushl $operatie
    push $formatScanf
    call scanf
    addl $8,%esp

    #compar operatia cu 1,2,3,4 pentru a-mi da seama ce operatie este de facut

    movl operatie,%ebx
    cmpl %ebx,add
    je et_add
    
    movl operatie,%ebx
    cmpl %ebx,get
    je et_get
    
    movl operatie,%ebx
    cmpl %ebx,delete
    je et_delete
    
    movl operatie,%ebx
    cmpl %ebx,defragmentation
    je et_defragmentation
    
    jmp operatii

et_add:

    #citesc cate fisiere adaug
    pushl $cate_fisiere
    push $formatScanf
    call scanf
    addl $8,%esp

    xorl %ecx,%ecx
    movl %ecx,ecx_copy

    #for care citeste cate_fisiere si dimensiunile lor

    add_for_nr_fisiere: 

        movl ecx_copy,%ecx
        cmpl cate_fisiere,%ecx 
        je add_exit
        incl %ecx
        movl %ecx,ecx_copy

    #citesc nr fisierului (descriptorul) si dimensiunea lui

        pushl $nr_fisier
        push $formatScanf
        call scanf
        addl $8,%esp

        pushl $dimensiune_fisier
        push $formatScanf
        call scanf
        addl $8,%esp
        
        movl $0,ok_add

        movl dimensiune_fisier,%eax
        xorl %edx,%edx
        divl impartire_opt
        cmpl $0,%edx
        jne aproximare_superioara

        revenire_add_dimensiune_fisier:
        movl %eax,nr_blocuri

        #incepe for-ul pentru verificarea blocurilor consecutive libere

        movl $0,contor_add
        xorl %ecx,%ecx #contor index_add
        lea v,%edi

        for_succesiune:

        cmpl dimensiune_vector,%ecx
        je et_afisare_add_not_found
        movl (%edi,%ecx,4),%ebx
        
        cmpl $0,%ebx
        je et_incrementare_contor_add
        
        # Dacă găsim o poziție ocupată, resetăm contorul și continuăm
        movl $0,contor_add
        incl %ecx
        jmp for_succesiune



et_incrementare_contor_add:
    incl contor_add
    movl nr_blocuri,%eax
    cmpl contor_add,%eax
    je et_succesiune_gasita_add    
    incl %ecx                      
    jmp for_succesiune


et_succesiune_gasita_add:
	movl $1,ok_add

    subl contor_add,%ecx    
    addl $1,%ecx
    movl %ecx,block_inceput
        
    movl %ecx,%ebx
    addl nr_blocuri,%ebx
    subl $1,%ebx

    movl block_inceput,%edx

et_for_populare:
	cmpl %ebx,%edx
	jg et_afisare_add
	movl nr_fisier,%eax
	movl %eax,(%edi,%edx,4)
	incl %edx
	jmp et_for_populare

    jmp add_for_nr_fisiere

                
                
add_exit:
    jmp operatii

aproximare_superioara:
    addl $1,%eax
    jmp revenire_add_dimensiune_fisier

et_resetare_contor:
    movl $0,contor_add
    jmp for_succesiune


et_afisare_add:
	cmpl $0,ok_add
    je et_afisare_add_not_found

    movl %eax,eax_copy
    movl %edx,edx_copy
        
    movl block_inceput,%eax
    movl %ebx,%edx        
        
    pushl %ebx           
    pushl block_inceput  
    pushl nr_fisier
    push $formatAfisAdd
    call printf
    addl $16,%esp
    pushl $0
    call fflush
    addl $4,%esp
    movl edx_copy,%edx
    movl eax_copy,%eax

    jmp add_for_nr_fisiere


et_afisare_add_not_found:
    movl %eax,eax_copy
    movl %edx,edx_copy
    pushl nr_fisier
    push $formatAfisAddNotFound
    call printf
    addl $8,%esp
    pushl $0
    call fflush
    addl $4,%esp
    movl edx_copy,%edx
    movl eax_copy,%eax

    jmp add_for_nr_fisiere


et_get:
    #citesc descriptorul pe care il caut

    pushl $descriptor_get
    push $formatScanf
    call scanf
    addl $8,%esp

    movl $0,get_inceput
    decl get_inceput

    xorl %ecx,%ecx

    #incepe for-ul pentru get

        for_get:

        cmpl dimensiune_vector,%ecx
        je et_iesire_din_get

        movl (%edi,%ecx,4),%ebx

        cmpl descriptor_get,%ebx
        je et_get_gasit

        et_revenire_de_la_actualizare_get:

        incl %ecx
        jmp for_get

    jmp operatii

et_get_gasit:

    cmpl $-1,get_inceput
    je et_actualizare_get_inceput

    et_continuare_pentru_get:

    movl %ecx,get_final

    jmp et_revenire_de_la_actualizare_get

et_actualizare_get_inceput:
    
    movl %ecx,get_inceput
    jmp et_continuare_pentru_get


et_iesire_din_get:
    cmpl $-1,get_inceput
    je get_not_found

    pushl get_final
    pushl get_inceput
    push $formatGetFound
    call printf
    addl $12,%esp

    pushl $0
    call fflush
    addl $4,%esp

    jmp operatii

get_not_found:  

    push $formatGetNotFound
    call printf
    addl $4,%esp

    pushl $0
    call fflush
    addl $4,%esp

    jmp operatii


et_delete:

    #citesc descriptorul pe care vreau sa-l sterg

    pushl $descriptor_delete
    push $formatScanf
    call scanf
    addl $8,%esp

    xorl %ecx,%ecx #index_delete pentru for

    #incep for-ul pentru cautarea descriptorului de sters

    for_delete:
    
    cmpl dimensiune_vector,%ecx
    je et_afisare_delete

    movl (%edi,%ecx,4),%ebx
    cmpl descriptor_delete,%ebx
    je et_introducere_zero_del

    et_revenire_del:

    incl %ecx
    jmp for_delete


    jmp operatii

et_introducere_zero_del:
    
    movl $0,%ebx
    movl %ebx,(%edi,%ecx,4)
    jmp et_revenire_del

et_afisare_delete:
    
    movl $0,descriptor_curent
    movl $-1,block_inceput

    #incepe for-ul pentru afisare delete

    xorl %ecx,%ecx

    for_afis_del:

    cmpl dimensiune_vector,%ecx
    je verifica_daca_e_la_final
    movl (%edi,%ecx,4),%ebx
    cmpl $0,%ebx
    je et_element_zero

    cmpl $-1,block_inceput
    je inceput_bloc_nou

    cmpl descriptor_curent,%ebx
    jne afiseaza_si_incepe_nou

    continua_for:

        incl %ecx
        jmp for_afis_del

        et_element_zero:
            movl block_inceput,%edx
            cmpl $-1,%edx
            jne afiseaza_bloc
            jmp continua_for

        inceput_bloc_nou:
            movl %ecx,block_inceput
            movl %ebx,descriptor_curent
            jmp continua_for

    afiseaza_si_incepe_nou:
        movl %ecx,%eax
        decl %eax

        pushl %ecx
        pushl %ebx

        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd
        call printf
        addl $16,%esp

        pushl $0
        call fflush
        addl $4,%esp

        popl %ebx
        popl %ecx

        movl %ecx,block_inceput
        movl %ebx,descriptor_curent
        jmp continua_for
    
    afiseaza_bloc:
        movl %ecx,%eax
        decl %eax
        
        pushl %ecx
        
        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd
        call printf
        addl $16,%esp
        
        pushl $0
        call fflush
        addl $4,%esp
        
        popl %ecx
        
        movl $-1,block_inceput
        jmp continua_for
    
    verifica_daca_e_la_final:

        cmpl $-1,block_inceput
        je final_delete
        
    # afisez ultimul bloc daca e populat
        movl dimensiune_vector,%eax
        decl %eax
        
        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd
        call printf
        addl $16,%esp
        
        pushl $0
        call fflush
        addl $4,%esp

        final_delete:
        jmp operatii
    
   

et_defragmentation:

    movl $1,%ecx                        #index_frag

    for_defragmentation:

        cmpl dimensiune_vector,%ecx
        jge et_afisare_defrag

        movl (%edi,%ecx,4),%eax
        cmpl $0,%eax
        je continua_for_defragmentation

        movl %ecx,ecx_copy

while_defragmentation:

    cmpl $0,%ecx 
    je restaurare_ecx

    movl %ecx,%ebx
    decl %ebx                       #ebx=index_frag-1
    movl (%edi,%ebx,4),%edx         #edx=v[index_frag-1]

    cmpl $0,%edx
    jne restaurare_ecx

    #swap intre elemente 

    movl (%edi,%ecx,4),%eax
    movl %eax,(%edi,%ebx,4)
    movl $0,(%edi,%ecx,4)

    decl %ecx
    jmp while_defragmentation

restaurare_ecx:
    movl ecx_copy,%ecx

continua_for_defragmentation:
    incl %ecx
    jmp for_defragmentation

et_afisare_defrag:
    #functioneaza la fel ca afisarea de la delete - este folosit acelasi principiu

    movl $0,descriptor_curent
    movl $-1,block_inceput

    #incepe for-ul pentru afisarea dupa defragmentare

    xorl %ecx,%ecx

    for_afis_defrag:

    cmpl dimensiune_vector,%ecx
    je verifica_daca_e_la_final_defrag
    movl (%edi,%ecx,4),%ebx
    cmpl $0,%ebx
    je et_element_zero_defrag

    cmpl $-1,block_inceput
    je inceput_bloc_nou_defrag

    cmpl descriptor_curent,%ebx
    jne afiseaza_si_incepe_nou_defrag

    continua_for_defrag:

        incl %ecx
        jmp for_afis_defrag

        et_element_zero_defrag:
            movl block_inceput,%edx
            cmpl $-1,%edx
            jne afiseaza_bloc_defrag
            jmp continua_for_defrag

        inceput_bloc_nou_defrag:
            movl %ecx,block_inceput
            movl %ebx,descriptor_curent
            jmp continua_for_defrag

    afiseaza_si_incepe_nou_defrag:

        movl %ecx,%eax
        decl %eax

        pushl %ecx
        pushl %ebx

        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd
        call printf
        addl $16,%esp

        pushl $0
        call fflush
        addl $4,%esp

        popl %ebx
        popl %ecx

        movl %ecx,block_inceput
        movl %ebx,descriptor_curent
        jmp continua_for_defrag
    
    afiseaza_bloc_defrag:
        movl %ecx,%eax
        decl %eax
        
        pushl %ecx
        
        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd
        call printf
        addl $16,%esp
        
        pushl $0
        call fflush
        addl $4,%esp
        
        popl %ecx
        
        movl $-1,block_inceput
        jmp continua_for_defrag
    
    verifica_daca_e_la_final_defrag:

        cmpl $-1,block_inceput
        je final_defrag 
        
    # afisez ultimul bloc daca e populat
        movl dimensiune_vector,%eax
        decl %eax
        
        pushl %eax
        pushl block_inceput
        pushl descriptor_curent
        push $formatAfisAdd 
        call printf
        addl $16,%esp
        
        pushl $0
        call fflush
        addl $4,%esp

        final_defrag:
        jmp operatii

et_exit:
    pushl $0
    call fflush
    popl %eax

    movl $1,%eax
    xor %ebx,%ebx
    int $0x80