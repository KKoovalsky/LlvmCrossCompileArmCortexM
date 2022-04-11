#!/usr/bin/env python3
import os.path as path
from pathlib import Path
import subprocess

# Supported architecture dictionary layout:
#   'cpu': string (e.g. 'cortex-m0')
#   'float': list (e.g. ['fpv4-sp-d16', 'soft'])


def build_multiple_archs():
    target_compiler_flags_set = \
        load_target_compiler_flags_for_supported_archs()
    create_build_directory()
    download_dependencies()
    for target_compiler_flags in target_compiler_flags_set:
        build_multi_config(target_compiler_flags)
        build_multi_config(target_compiler_flags, disable_exceptions=True)


def load_target_compiler_flags_for_supported_archs():
    supported_archs = load_supported_archs()
    target_compiler_flags_set = list()
    for arch in supported_archs:
        target_compiler_flags_set.extend(flatenize_flags(arch))
    return [serialize_compiler_flags(f) for f in target_compiler_flags_set]


def load_supported_archs():
    main_readme_md_path = get_main_readme_md_path()
    readme_md_content = read_file(main_readme_md_path)
    supported_archs_section = extract_supported_architectures_section(
        readme_md_content)
    supported_archs = parse_supported_architectures_section(
        supported_archs_section)
    return supported_archs


def get_main_readme_md_path():
    main_readme_md_dir = get_project_root_dir()
    return path.join(main_readme_md_dir, 'README.md')


def read_file(path):
    with open(path) as f:
        return f.read()


def extract_supported_architectures_section(file_content: str):
    sought_header = '## Supported architectures:'
    begin = file_content.find(sought_header)
    begin += len(sought_header)
    end = file_content.find('##', begin)
    return file_content[begin:end]


def parse_supported_architectures_section(section_content: str):
    raw = section_content.split('*')
    raw_stripped = [l.strip() for l in raw]
    raw_entries = list(filter(lambda l: l.startswith('Cortex'), raw_stripped))
    entries = [r.split(',') for r in raw_entries]

    result = list()
    for entry in entries:
        # Remove the first 'Cortex M*' name and architecture name.
        # The architecture name will be resolved within the CMake scripts.
        entry.pop(0)
        entry.pop(0)
        parsed_entry = dict()
        for detail in entry:
            key, value = detail.split(':')
            parsed_entry[key.strip()] = value.strip()
        result.append(parsed_entry)

        floats = parsed_entry['float'].replace('[', '').replace(']', '')
        parsed_entry['float'] = [fl.strip() for fl in floats.split(';')]

    return result


def flatenize_flags(arch: dict):
    result = list()
    for float_support in arch['float']:
        arch_new = arch.copy()
        arch_new['float'] = float_support
        result.append(arch_new)
    return result


def serialize_compiler_flags(arch: dict):
    cpu = arch['cpu']
    flags = '-mthumb -mcpu={} '.format(cpu)
    float_support = arch['float']
    if float_support == 'soft':
        flags += '-mfloat-abi=soft'
    else:
        flags += '-mfloat-abi=hard -mfpu={}'.format(float_support)
    name = '{}_{}'.format(cpu, float_support)
    return (name, flags)


def get_project_root_dir():
    this_script_file_dir = path.dirname(path.realpath(__file__))
    root_dir = path.normpath(path.join(this_script_file_dir, '..'))
    return root_dir


def get_build_directory():
    root_dir = get_project_root_dir()
    return path.join(root_dir, 'build_multiple_archs')


def create_build_directory():
    build_dir = get_build_directory()
    Path(build_dir).mkdir(exist_ok=True)


def download_dependencies():
    local_build_dir = get_build_with_dependencies_downloaded_directory()
    Path(local_build_dir).mkdir(exist_ok=True)
    basic_configure_and_generate_cmd = ['cmake', '-GUnix Makefiles', '../..']

    # Run basic configure and generate command. Do not care about the
    # architecture flags. We only do it to have a build directory where all
    # the dependencies are downloaded.
    print('Downloading dependencies ... (May take few minutes)')
    subprocess.run(basic_configure_and_generate_cmd, cwd=local_build_dir)


def build_multi_config(target_compiler_flags, disable_exceptions=False):
    deps_dir = get_dependencies_location()
    llvm_dir = path.join(deps_dir, 'llvm-src')
    arm_gnu_toolchain_dir = path.join(deps_dir, 'armgnutoolchain-src')
    llvm_project_dir = path.join(deps_dir, 'llvmproject-src')

    name, flags = target_compiler_flags
    local_build_dir = path.join(get_build_directory(), 'build_{}'.format(name))
    if disable_exceptions:
        local_build_dir += '_no_exceptions'
    Path(local_build_dir).mkdir(exist_ok=True)

    configurations = ['Release', 'Debug', 'MinSizeRel']
    configure_and_generate_cmd = [
        'cmake',
        '-GNinja Multi-Config',
        '-DFETCHCONTENT_SOURCE_DIR_LLVM={}'.format(llvm_dir),
        '-DFETCHCONTENT_SOURCE_DIR_ARMGNUTOOLCHAIN={}'.format(
            arm_gnu_toolchain_dir),
        '-DFETCHCONTENT_SOURCE_DIR_LLVMPROJECT={}'.format(llvm_project_dir),
        '-DCMAKE_CONFIGURATION_TYPES={}'.format(';'.join(configurations)),
        '-DLLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS={}'.format(flags)]
    if disable_exceptions:
        configure_and_generate_cmd.extend([
            '-DLIBCXXABI_ENABLE_EXCEPTIONS=OFF',
            '-DLIBCXX_ENABLE_EXCEPTIONS=OFF'])
    configure_and_generate_cmd.append('../..')

    print('>' * 120)
    print('Running configure and generate step for target: {}'.format(name))
    subprocess.run(configure_and_generate_cmd, cwd=local_build_dir)

    print('Running building and packing for target: {}'.format(name))
    for config in configurations:
        subprocess.run(['cmake', '--build', '.', '--config', config],
                       cwd=local_build_dir)
        subprocess.run(
            ['cmake', '--build', '.', '--target', 'pack', '--config', config],
            cwd=local_build_dir)

    print('<' * 120)


def get_build_with_dependencies_downloaded_directory():
    build_dir = get_build_directory()
    return path.join(build_dir, 'build_with_deps_downloaded')


def get_dependencies_location():
    build_with_deps_downloaded_dir = \
        get_build_with_dependencies_downloaded_directory()
    return path.join(build_with_deps_downloaded_dir, '_deps')


if __name__ == "__main__":
    build_multiple_archs()
