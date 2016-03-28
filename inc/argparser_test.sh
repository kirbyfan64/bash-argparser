source ./argparser

function action_callback() { :; }
function check_callback() { :; }
function callback() { :; }

function test_argparser()
{
    printf '%s: ' 'argparser should store the right value to globals varibles'

    local app_name='fakeapp'
    local prologue='prologue'
    local usage='%(prog_name) %(other_difine_string) do something'
    local add_help=true
    local description='app description'
    local epilog='Author: ekeyme'
    local help=callback
    local prefix_chars='-+'
    local nargs_extending_EOT='!'

    argparser $app_name \
        prefix_chars="$prefix_chars" prologue="$prologue" \
        usage="$usage" \
        add_help="$add_help" description="$description" \
        epilog="$epilog" \
        help="$help" \
        nargs_extending_EOT="$nargs_extending_EOT"

    if [[ $Argparser_prog_name = $app_name ]] && \
            [[ $Argparser_prologue = $prologue ]] && \
            [[ $Argparser_usage = $usage ]] && \
            [[ $Argparser_add_help = $add_help ]] && \
            [[ $Argparser_description = $description ]] && \
            [[ $Argparser_epilog = $epilog ]] && \
            [[ $Argparser_help = $help ]] && \
            [[ $Argparser_prefix_chars = $prefix_chars ]]
    then
        echo ok
    else
        echo fail
    fi
}

function test__parse_parameters()
{
    argparser
    printf '%s: ' 'parse_parameters should give the right value when has more than 1 options to parse'
    v='ekeyme
    dsf
    fdsf'\''d

    sdsf'\'
    in_parameter=(NAME=name AGE=age -- name="$v" age=26)
    _parse_parameters "${in_parameter[@]}"

    if [[ ( $NAME = $v ) && ( $AGE = 26 ) ]]; then
        echo ok
    else
        echo fail
    fi
}

function test__parse_parameters2()
{
    argparser
    printf '%s: ' 'parse_parameters should exit when get invalid varible name'
    in_parameter=('invalid varible name'=name -- name=ekeyme)
    if (_parse_parameters "${in_parameter[@]}"); then
        echo fail
    else
        echo ok
    fi
}

function test__parse_parameters3()
{
    argparser
    printf '%s: ' 'parse_parameters should exit when get unkonwn to parsing option'
    in_parameter=('NAME'=name -- name=ekeyme unkonwn_option=kk)
    if (_parse_parameters "${in_parameter[@]}"); then
        echo fail
    else
        echo ok
    fi
}

function test__parse_parameters4()
{
    argparser
    printf '%s: ' 'parse_parameters should give the right value when has just 1 option to parse'
    v='ekeyme
    dsf
    fdsf'\''d

    sdsf'\'
    in_parameter=(NAME=name -- name="$v")
    _parse_parameters "${in_parameter[@]}"

    if [[ $NAME = $v ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_argparser_add_arg()
{
    argparser
    printf '%s: ' 'argparser_add_arg should give right array to store data'
    local dest=(dest dest1)
    local check=(check_callback check_callback)
    local action=(action_callback action_callback)
    local desc=(desc desc1)
    local metavar=(metavar metavar1)
    local required=(required required1)
    local choices=(choices choices1)
    local default=(default default1)
    local const=(const const1)
    local nargs=(nargs nargs1)
    argparser_add_arg -n --name \
        dest=${dest[0]} check=${check[0]} action=${action[0]} desc=${desc[0]} \
        metavar=${metavar[0]} required=${required[0]} choices=${choices[0]} \
        default=${default[0]} const=${const[0]} nargs=${nargs[0]}
    argparser_add_arg -a --age \
        dest=${dest[1]} check=${check[1]} action=${action[1]} desc=${desc[1]} \
        metavar=${metavar[1]} required=${required[1]} choices=${choices[1]} \
        default=${default[1]} const=${const[1]} nargs=${nargs[1]}

    if [[ '-a|--age' = ${Argparser_option_strings[1]} ]] && \
            [[ ${dest[1]} = ${Argparser_option_dest[1]} ]] && \
            [[ ${check[1]} = ${Argparser_option_check[1]} ]] && \
            [[ ${action[1]} = ${Argparser_option_action[1]} ]] && \
            [[ ${default[1]} = ${Argparser_option_default[1]} ]] && \
            [[ ${const[1]} = ${Argparser_option_const[1]} ]] && \
            [[ ${nargs[1]} = ${Argparser_option_nargs[1]} ]] && \
            [[ ${desc[1]} = ${Argparser_option_desc[1]} ]] && \
            [[ ${metavar[1]} = ${Argparser_option_metavar[1]} ]] && \
            [[ ${required[1]} = ${Argparser_option_required[1]} ]] && \
            [[ ${choices[1]} = ${Argparser_option_choices[1]} ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_argparser_add_arg1()
{
    argparser
    printf '%s: ' 'argparser_add_arg should raise error when const not supply and nargs is 0|?|*'

    if (argparser_add_arg -n --name nargs='0'); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_add_arg2()
{
    argparser
    printf '%s: ' 'argparser_add_arg should give the right nargs for position argment'
    argparser_add_arg name default='has default'
    argparser_add_arg age
    set -- "${Argparser_argument_nargs[@]}"
    if [[ $2 = '?' && $3 = 1 ]]; then
        echo ok
    else
        echo fail
    fi
}

function test_argparser_add_arg3()
{
    argparser
    printf '%s: ' 'argparser_add_arg should not support const/required option for position argment'
    if (argparser_add_arg name const='this should not supply' ) && \
            (argparser_add_arg age required=true ); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_add_arg4()
{
    argparser
    printf '%s: ' 'argparser_add_arg should not support >1 position argments'
    if (argparser_add_arg name name2); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_parse()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should give the right values of options'
    argparser_add_arg files nargs=+
    argparser_add_arg dest nargs=1

    # test 1
    cl_args=(file1 file2 file3 file4)
    files_expected=(file1 file2 file3)
    dest_expected=(file4)
    argparser_parse "${cl_args[@]}"
    if is_the_same_arr "${files_expected[@]}" -- "${files[@]}" &&\
        is_the_same_arr "${dest_expected[@]}" -- "${dest[@]}"; then
            echo ok
    else
        echo fail
    fi
}

function test_argparser_parse1()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should give the right values of options'
    argparser_add_arg file nargs=1
    argparser_add_arg dest_dirs nargs=+
    args=(file1 file2 'dd ff f' file4)
    file_ex=(file1)
    dest_dirs_ex=(file2 'dd ff f' file4)
    argparser_parse "${args[@]}"
    if is_the_same_arr "${file_ex[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${dest_dirs_ex[@]}" -- "${dest_dirs[@]}"; then
            echo ok
    else
        echo fail
    fi
}

function test_argparser_parse2()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should give the right values of options'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -q dest=quit_model default=false const=true nargs=0
    argparser_add_arg -n --name default=ekeyme nargs=?
    argparser_add_arg -e --emails dest=emails nargs=2
    argparser_add_arg money dest=how_much nargs=1
    argparser_add_arg currency nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg source default='Guangzhou Doc' nargs='?'
    
    # test 1
    arg=(-vqeekeyme@gmail.com ekeyme@foxmail.com 9999 dollar Beijing Hongkong - Zhanjiang)
    e_verbose=(true)
    e_quit_model=(true)
    e_name=(ekeyme)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong)
    e_source=(Zhanjiang)
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"; then
            :
    else
        echo test 1: fail
        exit 1
    fi

    # test 2
    arg=(-vqeekeyme@gmail.com ekeyme@foxmail.com 9999 dollar Beijing Hongkong Zhanjiang)
    e_verbose=(true)
    e_quit_model=(true)
    e_name=(ekeyme)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong Zhanjiang)
    e_source=('Guangzhou Doc')
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"; then
            :
    else
        echo test 2: fail
        exit 1
    fi

    # test 3
    arg=(-v -e ekeyme@gmail.com ekeyme@foxmail.com 9999 -n mozz dollar Beijing Hongkong Zhanjiang)
    e_verbose=(true)
    e_quit_model=(false)
    e_name=(mozz)
    e_emails=(ekeyme@gmail.com ekeyme@foxmail.com)
    e_how_much=(9999)
    e_currency=(dollar)
    e_distribution_to=(Beijing Hongkong Zhanjiang)
    e_source=('Guangzhou Doc')
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_quit_model[@]}" -- "${quit_model[@]}" &&\
        is_the_same_arr "${e_name[@]}" -- "${name[@]}" &&\
        is_the_same_arr "${e_emails[@]}" -- "${emails[@]}" &&\
        is_the_same_arr "${e_how_much[@]}" -- "${how_much[@]}" &&\
        is_the_same_arr "${e_currency[@]}" -- "${currency[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_source[@]}" -- "${source[@]}"; then
            :
    else
        echo test 3: fail
        exit 1
    fi

    echo ok
}

function test_argparser_parse3()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should give the right values of options'
    argparser_add_arg -v dest=verbose default=false const=true nargs=0
    argparser_add_arg -f --file default=ekeyme nargs=+
    argparser_add_arg -t --type default=r nargs=1
    argparser_add_arg distribution_to default='/tmp' nargs='*'
    argparser_add_arg user default=mozz nargs=?

    # test 1
    arg=(-vf file1 file2 file3 -tdir magic castor - zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"; then
            :
    else
        echo test 1: fail
        exit 1
    fi

    # test 2
    arg=(-vf file1 file2 file3 - magic castor -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"; then
            :
    else
        echo test 2: fail
        exit 1
    fi

    # test 3
    arg=(-v magic castor -f file1 file2 file3 -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"; then
            :
    else
        echo test 3: fail
        exit 1
    fi

    # test 4
    arg=(magic castor -v -f file1 file2 file3 -tdir zj)
    e_verbose=(true)
    e_file=(file1 file2 file3)
    e_type=('dir')
    e_distribution_to=(magic castor)
    e_user=(zj)
    argparser_parse "${arg[@]}"
    if is_the_same_arr "${e_verbose[@]}" -- "${verbose[@]}" &&\
        is_the_same_arr "${e_file[@]}" -- "${file[@]}" &&\
        is_the_same_arr "${e_type[@]}" -- "${type[@]}" &&\
        is_the_same_arr "${e_distribution_to[@]}" -- "${distribution_to[@]}" &&\
        is_the_same_arr "${e_user[@]}" -- "${user[@]}"; then
            :
    else
        echo test 4: fail
        exit 1
    fi

    echo ok
}

function test_argparser_parse4()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse exit when required argument does not be supplied'
    argparser
    argparser_add_arg -f dest=file required=true
    argparser_add_arg -n dest=name nargs=1
    if (argparser_parse -n ekeyme); then
        echo fail
    else
        echo ok
    fi
}

function test_argparser_parse99()
{
    argparser
    printf '%s: %s: ' "$FUNCNAME" 'argparser_parse should print help doc and exit.'
    argparser
    if (argparser_parse -h); then
        echo fail
    else
        echo ok
    fi
}

function is_the_same_arr()
{
    local arr1=()
    local arr2=()
    while (($# > 0)); do
        if [[ $1 == '--' ]]; then
            shift
            while (($# > 0)); do
                arr2=("${arr2[@]}" "$1")
                shift
            done
        else
            arr1=("${arr1[@]}" "$1")
            shift
        fi
    done
    local i v1 v2
    ((${#arr1[@]} == ${#arr2[@]})) && ((${#arr1[@]} > 0)) &&\
        for ((i=0; i < ${#arr1[@]}; i++)); do
            v1=${arr1[$i]}
            v2=${arr2[$i]}
            if [[ $v1 != $v2 ]]; then
                return 1
            fi
        done
}

(test_argparser)
(test_argparser_add_arg2)
(test_argparser_add_arg3)
(test_argparser_add_arg4)
(test_argparser_parse)
(test_argparser_parse1)
(test_argparser_parse2)
(test_argparser_parse3)
(test_argparser_parse4)
(test_argparser_parse99)