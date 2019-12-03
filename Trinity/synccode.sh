
checkoutMaster() {
#   skip submodule:Dependency/SPV.Cpp
    git submodule foreach '
        if [ "$path" != "Dependency/SPV.Cpp" ]; then
            git checkout master
        fi'
}

syncCode() {
    git pull --rebase
    git submodule update --init --rebase
}

checkoutMaster
syncCode
