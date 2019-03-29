#!/usr/bin/env bash

# utility methods

function print_banner() {
    echo $''
    echo $' __   __                   __   __       ___    __                            __       ___  __   __  '
    echo $'|__) |  \ |  |     |\/| | / _` |__)  /\   |  | /  \ |\ |    \  /  /\  |    | |  \  /\   |  /  \ |__) '
    echo $'|  \ |__/ |/\|     |  | | \__> |  \ /~~\  |  | \__/ | \|     \/  /~~\ |___ | |__/ /~~\  |  \__/ |  \ '
    echo $''
}

function now_in_seconds() {
    echo `date -u +%s`;
}

function now_in_YYYY_mm_dd_HHMMSS() {
    echo `date '+%Y-%m-%d-%H%M%S'`
}

function format_seconds_to_HH_MM_SS() {
    echo `date -u -r $1 +%T`
}

function get_property_by_index() {
    echo $1 | cut -f${2} -d"|"
}

function print_connection() {
    declare -a connection=("${!1}")
    echo "${connection[3]} @ ${connection[0]}:${connection[1]}/${connection[2]}"
}

function mysql_to_csv() {
    declare -a connection=("${!1}")
    mysql -h ${connection[0]} -P ${connection[1]} -u ${connection[3]} ${connection[2]} -p${connection[4]} -s < ${2} 2>&1 | grep -v "Warning: Using a password" | tr '\t' ','
}

function psql_to_csv() {
    declare -a connection=("${!1}")
    psql postgresql://${connection[3]}:${connection[4]}@${connection[0]}:${connection[1]}/${connection[2]} -t -F, -A -f ${2}
}

function run_tests() {
    declare -a tests=("${!1}")
    for test in "${tests[@]}"
    do
        run_test_and_compare_results ${test} $2 $3 $4 $5
    done
}

function run_test() {
    local database_type=$1
    local sql_file=$2
    local test_name=`get_property_by_index $3 1`
    local test_headers=`get_property_by_index $3 2`
    declare -a connection=("${!4}")
    local csv_file=`mktemp`
    echo "${test_headers}" >> ${csv_file}
    if [[ "${database_type}" == "mysql" ]]; then
        mysql_to_csv connection[@] ${sql_file} >> ${csv_file}
    else
        psql_to_csv connection[@] ${sql_file} >> ${csv_file}
    fi
    echo "${csv_file}"
}

function compare_test_results() {
    local test_name=$1
    local a_namespace=$2
    local a=$3
    local b_namespace=$4
    local b=$5
    local test_result_dir=$6
    local comparison_file=`mktemp`

    diff ${diff_options} ${a} ${b} > ${comparison_file}

    local total_differences=$(( `cat ${comparison_file} | wc -l` ))

    mkdir -p ${test_result_dir}
    mv ${a} ${test_result_dir}/${a_namespace}.csv
    mv ${b} ${test_result_dir}/${b_namespace}.csv

    if [[ "${total_differences}" == "0" ]]; then
        let passed++
        echo "  ${a_namespace}/${b_namespace} (passed)"
    else
        local diff_file=${test_result_dir}/${a_namespace}_${b_namespace}.diff
        mv ${comparison_file} ${diff_file}
        diff_files+=(${diff_file})
        echo "  ${a_namespace}/${b_namespace} (${total_differences} differences) ${diff_file}"
    fi
}

# setting dependent methods

function run_test_and_compare_results() {

    local test_name=`get_property_by_index $1 1`
    local reporting_sql=$3
    local warehouse_sql=$4

    # get data from reporting_olap and compare
    local the_reporting_sql=${sql_dir}/${test_name}/${reporting_sql}.sql
    if [[ -f ${the_reporting_sql} ]]; then
        echo "`date -u +%T` Running Test: ${test_name}"

        echo "getting data from warehouse"
        # get data from warehouse
        local warehouse_csv=`run_test "mysql" ${sql_dir}/${test_name}/${warehouse_sql}.sql $1 warehouse_connection[@]`

        echo "getting data from reporting"
        local reporting_csv=`run_test $2 ${the_reporting_sql} $1 $5`
        compare_test_results ${test_name} ${warehouse_sql} ${warehouse_csv} ${reporting_sql} ${reporting_csv} ${out_dir}/${test_name}

        echo ''
    fi
}

function print_settings() {
    echo "validating..."
    echo "  output folder: ${out_dir}"
    echo "  warehouse connection:      $(print_connection warehouse_connection[@])"
    echo "  reporting connection:      $(print_connection reporting_connection[@])"
    echo "  reporting olap connection: $(print_connection reporting_olap_connection[@])"
    echo ''
}

function print_summary() {
    local end_time=`now_in_seconds`
    local elapsed_time_formatted=`format_seconds_to_HH_MM_SS $(($end_time-$start_time))`
    echo "completed in ${elapsed_time_formatted}"

    echo "${passed} tests passed with no differences"
    if [[ ${#diff_files[@]} -gt 0 ]]; then
        echo "differences found:"
        for f in ${diff_files[@]}; do
            echo "  $f"
        done
    fi
}

### Entry Point ###

print_banner

# process input
if [[ ! -f "$1" ]]; then
  echo "usage: validate-migration <config-file> [olap|reporting]"
  exit 1
fi
source $1

# what tests will be run?
[[ $# == 1 ]] || [[ $2 == reporting ]] && run_reporting=1 || run_reporting=0
[[ $# == 1 ]] || [[ $2 == olap ]] && run_olap=1 || run_olap=0

# validate settings and exit if any values not set or empty
[[ -z "${warehouse_host}" ]] && echo "warehouse_host must be set" && exit 1
[[ -z "${warehouse_port}" ]] && echo "warehouse_port must be set" && exit 1
[[ -z "${warehouse_schema}" ]] && echo "warehouse_schema must be set" && exit 1
[[ -z "${warehouse_user}" ]] && echo "warehouse_user must be set" && exit 1
[[ -z "${warehouse_password}" ]] && echo "warehouse_password must be set" && exit 1

[[ ${run_reporting} == 1 ]] && [[ -z "${reporting_host}" ]] && echo "reporting_host must be set" && exit 1
[[ ${run_reporting} == 1 ]] && [[ -z "${reporting_port}" ]] && echo "reporting_port must be set" && exit 1
[[ ${run_reporting} == 1 ]] && [[ -z "${reporting_schema}" ]] && echo "reporting_schema must be set" && exit 1
[[ ${run_reporting} == 1 ]] && [[ -z "${reporting_user}" ]] && echo "reporting_user must be set" && exit 1
[[ ${run_reporting} == 1 ]] && [[ -z "${reporting_password}" ]] && echo "reporting_password must be set" && exit 1

[[ ${run_olap} == 1 ]] && [[ -z "${reporting_olap_host}" ]] && echo "reporting_olap_host must be set" && exit 1
[[ ${run_olap} == 1 ]] && [[ -z "${reporting_olap_port}" ]] && echo "reporting_olap_port must be set" && exit 1
[[ ${run_olap} == 1 ]] && [[ -z "${reporting_olap_db}" ]] && echo "reporting_olap_db must be set" && exit 1
[[ ${run_olap} == 1 ]] && [[ -z "${reporting_olap_user}" ]] && echo "reporting_olap_user must be set" && exit 1
[[ ${run_olap} == 1 ]] && [[ -z "${reporting_olap_password}" ]] && echo "reporting_olap_password must be set" && exit 1

# settings
start_time=`now_in_seconds`
base_dir=`cd "$(dirname "$0")" ; pwd -P`
sql_dir=${base_dir}/sql
out_dir="${base_dir}/results-$(now_in_YYYY_mm_dd_HHMMSS)"
diff_options="-y --suppress-common-lines -W 200"
passed=0
diff_files=()

# (host port schema user password)
declare -a warehouse_connection=("${warehouse_host}" "${warehouse_port}" "${warehouse_schema}" "${warehouse_user}" "${warehouse_password}")
declare -a reporting_connection=("${reporting_host}" "${reporting_port}" "${reporting_schema}" "${reporting_user}" "${reporting_password}")
declare -a reporting_olap_connection=("${reporting_olap_host}" "${reporting_olap_port}" "${reporting_olap_db}" "${reporting_olap_user}" "${reporting_olap_password}")

# name|headers
declare -a tests=(
    "total-ica|total_exams"
    "total-ica-scores|total_scale_score,total_standard_error,total_performance_level"
    "total-ica-by-asmt-schoolyear-condition-complete|total_exams,assessment_id,school_year,administrative_condition,complete"
    "total-ica-by-school-district|total_exams,school_id,district_name,school_name"
    "total-iab|total_exams"
    "total-iab-scores|total_scale_score,total_standard_error,total_performance_level"
    "total-iab-by-asmt-schoolyear-condition-complete|total_exams,assessment_id,school_year,administrative_condition,complete"
    "total-iab-by-school-district|total_exams,school_id,district_name,school_name"
    "student-groups-by-school|district_name,district_id,school_name,school_id,total_groups"
    "student-groups-by-year|school_year,total_groups"
)

print_settings
if [[ ${run_olap} == 1 ]]; then
    echo "************ Running reporting olap tests ************"
    # 'olap_reporting' and 'olap_warehouse' are used to lookup the SQL test files, they also dictate the naming of the output csv and diff files
    run_tests tests[@] psql olap_reporting  olap_warehouse reporting_olap_connection[@]
fi

if [[ ${run_reporting} == 1 ]]; then
      echo "************ Running reporting tests ************"
      # 'reporting' and 'warehouse' are used to lookup the SQL test files, they also dictate the naming of the output csv and diff files
      run_tests tests[@] mysql reporting warehouse reporting_connection[@]
fi
print_summary
