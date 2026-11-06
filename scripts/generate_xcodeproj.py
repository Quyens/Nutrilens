#!/usr/bin/env python3
import os
import hashlib
import plistlib

def gen_id(name: str) -> str:
    h = hashlib.md5(name.encode("utf-8")).hexdigest().upper()
    return h[:24]

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    nutrilens_dir = os.path.join(root_dir, "NutriLens")
    tests_dir = os.path.join(root_dir, "NutriLensTests")
    uitests_dir = os.path.join(root_dir, "NutriLensUITests")

    # Discover swift files
    app_swift_files = []
    for r, _, files in os.walk(nutrilens_dir):
        for f in sorted(files):
            if f.endswith(".swift"):
                rel = os.path.relpath(os.path.join(r, f), root_dir)
                app_swift_files.append((rel, f))

    test_swift_files = []
    for r, _, files in os.walk(tests_dir):
        for f in sorted(files):
            if f.endswith(".swift"):
                rel = os.path.relpath(os.path.join(r, f), root_dir)
                test_swift_files.append((rel, f))

    uitest_swift_files = []
    for r, _, files in os.walk(uitests_dir):
        for f in sorted(files):
            if f.endswith(".swift"):
                rel = os.path.relpath(os.path.join(r, f), root_dir)
                uitest_swift_files.append((rel, f))

    proj_id = gen_id("PROJECT_NUTRILENS")
    main_group_id = gen_id("MAIN_GROUP")
    products_group_id = gen_id("PRODUCTS_GROUP")

    app_target_id = gen_id("TARGET_NUTRILENS")
    app_product_ref_id = gen_id("PRODUCT_REF_NUTRILENS_APP")
    app_sources_build_phase_id = gen_id("SOURCES_PHASE_NUTRILENS")
    app_resources_build_phase_id = gen_id("RESOURCES_PHASE_NUTRILENS")
    app_frameworks_build_phase_id = gen_id("FRAMEWORKS_PHASE_NUTRILENS")

    test_target_id = gen_id("TARGET_NUTRILENS_TESTS")
    test_product_ref_id = gen_id("PRODUCT_REF_NUTRILENS_TESTS")
    test_sources_build_phase_id = gen_id("SOURCES_PHASE_TESTS")
    test_frameworks_build_phase_id = gen_id("FRAMEWORKS_PHASE_TESTS")
    test_resources_build_phase_id = gen_id("RESOURCES_PHASE_TESTS")

    uitest_target_id = gen_id("TARGET_NUTRILENS_UITESTS")
    uitest_product_ref_id = gen_id("PRODUCT_REF_NUTRILENS_UITESTS")
    uitest_sources_build_phase_id = gen_id("SOURCES_PHASE_UITESTS")
    uitest_frameworks_build_phase_id = gen_id("FRAMEWORKS_PHASE_UITESTS")
    uitest_resources_build_phase_id = gen_id("RESOURCES_PHASE_UITESTS")

    assets_file_ref_id = gen_id("FILE_REF_ASSETS")
    assets_build_file_id = gen_id("BUILD_FILE_ASSETS")
    model_file_ref_id = gen_id("FILE_REF_FOODCLASSIFIER")
    model_build_file_id = gen_id("BUILD_FILE_FOODCLASSIFIER")

    # Start PBX objects dict
    objects = {}

    # File refs and build files for App sources
    app_sources_build_files = []
    app_group_children = []

    for rel, fname in app_swift_files:
        fref = gen_id(f"FILEREF_{rel}")
        bfile = gen_id(f"BUILDFILE_{rel}")
        objects[fref] = {
            "isa": "PBXFileReference",
            "lastKnownFileType": "sourcecode.swift",
            "path": rel,
            "sourceTree": "<group>"
        }
        objects[bfile] = {
            "isa": "PBXBuildFile",
            "fileRef": fref
        }
        app_sources_build_files.append(bfile)
        app_group_children.append(fref)

    # Assets
    objects[assets_file_ref_id] = {
        "isa": "PBXFileReference",
        "lastKnownFileType": "folder.assetcatalog",
        "path": "NutriLens/Resources/Assets.xcassets",
        "sourceTree": "<group>"
    }
    objects[assets_build_file_id] = {
        "isa": "PBXBuildFile",
        "fileRef": assets_file_ref_id
    }
    app_group_children.append(assets_file_ref_id)

    # Core ML Model
    objects[model_file_ref_id] = {
        "isa": "PBXFileReference",
        "lastKnownFileType": "wrapper.mlmodelc",
        "path": "NutriLens/AI/Models/FoodClassifier.mlmodelc",
        "sourceTree": "<group>"
    }
    objects[model_build_file_id] = {
        "isa": "PBXBuildFile",
        "fileRef": model_file_ref_id
    }
    app_group_children.append(model_file_ref_id)

    # Unit Tests sources
    test_sources_build_files = []
    test_group_children = []
    for rel, fname in test_swift_files:
        fref = gen_id(f"FILEREF_{rel}")
        bfile = gen_id(f"BUILDFILE_{rel}")
        objects[fref] = {
            "isa": "PBXFileReference",
            "lastKnownFileType": "sourcecode.swift",
            "path": rel,
            "sourceTree": "<group>"
        }
        objects[bfile] = {
            "isa": "PBXBuildFile",
            "fileRef": fref
        }
        test_sources_build_files.append(bfile)
        test_group_children.append(fref)

    # UI Tests sources
    uitest_sources_build_files = []
    uitest_group_children = []
    for rel, fname in uitest_swift_files:
        fref = gen_id(f"FILEREF_{rel}")
        bfile = gen_id(f"BUILDFILE_{rel}")
        objects[fref] = {
            "isa": "PBXFileReference",
            "lastKnownFileType": "sourcecode.swift",
            "path": rel,
            "sourceTree": "<group>"
        }
        objects[bfile] = {
            "isa": "PBXBuildFile",
            "fileRef": fref
        }
        uitest_sources_build_files.append(bfile)
        uitest_group_children.append(fref)

    # Product references
    objects[app_product_ref_id] = {
        "isa": "PBXFileReference",
        "explicitFileType": "wrapper.application",
        "includeInIndex": "0",
        "path": "NutriLens.app",
        "sourceTree": "BUILT_PRODUCTS_DIR"
    }
    objects[test_product_ref_id] = {
        "isa": "PBXFileReference",
        "explicitFileType": "wrapper.cfbundle",
        "includeInIndex": "0",
        "path": "NutriLensTests.xctest",
        "sourceTree": "BUILT_PRODUCTS_DIR"
    }
    objects[uitest_product_ref_id] = {
        "isa": "PBXFileReference",
        "explicitFileType": "wrapper.cfbundle",
        "includeInIndex": "0",
        "path": "NutriLensUITests.xctest",
        "sourceTree": "BUILT_PRODUCTS_DIR"
    }

    # Build phases
    objects[app_sources_build_phase_id] = {
        "isa": "PBXSourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": app_sources_build_files,
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[app_resources_build_phase_id] = {
        "isa": "PBXResourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": [assets_build_file_id, model_build_file_id],
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[app_frameworks_build_phase_id] = {
        "isa": "PBXFrameworksBuildPhase",
        "buildActionMask": "2147483647",
        "files": [],
        "runOnlyForDeploymentPostprocessing": "0"
    }

    # Test build phases
    objects[test_sources_build_phase_id] = {
        "isa": "PBXSourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": test_sources_build_files,
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[test_frameworks_build_phase_id] = {
        "isa": "PBXFrameworksBuildPhase",
        "buildActionMask": "2147483647",
        "files": [],
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[test_resources_build_phase_id] = {
        "isa": "PBXResourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": [],
        "runOnlyForDeploymentPostprocessing": "0"
    }

    # UI Test build phases
    objects[uitest_sources_build_phase_id] = {
        "isa": "PBXSourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": uitest_sources_build_files,
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[uitest_frameworks_build_phase_id] = {
        "isa": "PBXFrameworksBuildPhase",
        "buildActionMask": "2147483647",
        "files": [],
        "runOnlyForDeploymentPostprocessing": "0"
    }
    objects[uitest_resources_build_phase_id] = {
        "isa": "PBXResourcesBuildPhase",
        "buildActionMask": "2147483647",
        "files": [],
        "runOnlyForDeploymentPostprocessing": "0"
    }

    # Container item proxy & target dependencies
    test_proxy_id = gen_id("TEST_PROXY")
    test_dependency_id = gen_id("TEST_DEPENDENCY")
    objects[test_proxy_id] = {
        "isa": "PBXContainerItemProxy",
        "containerPortal": proj_id,
        "proxyType": "1",
        "remoteGlobalIDString": app_target_id,
        "remoteInfo": "NutriLens"
    }
    objects[test_dependency_id] = {
        "isa": "PBXTargetDependency",
        "target": app_target_id,
        "targetProxy": test_proxy_id
    }

    uitest_proxy_id = gen_id("UITEST_PROXY")
    uitest_dependency_id = gen_id("UITEST_DEPENDENCY")
    objects[uitest_proxy_id] = {
        "isa": "PBXContainerItemProxy",
        "containerPortal": proj_id,
        "proxyType": "1",
        "remoteGlobalIDString": app_target_id,
        "remoteInfo": "NutriLens"
    }
    objects[uitest_dependency_id] = {
        "isa": "PBXTargetDependency",
        "target": app_target_id,
        "targetProxy": uitest_proxy_id
    }

    # Groups
    objects[products_group_id] = {
        "isa": "PBXGroup",
        "children": [app_product_ref_id, test_product_ref_id, uitest_product_ref_id],
        "name": "Products",
        "sourceTree": "<group>"
    }

    app_group_id = gen_id("GROUP_NUTRILENS")
    objects[app_group_id] = {
        "isa": "PBXGroup",
        "children": app_group_children,
        "name": "NutriLens",
        "sourceTree": "<group>"
    }

    tests_group_id = gen_id("GROUP_NUTRILENSTESTS")
    objects[tests_group_id] = {
        "isa": "PBXGroup",
        "children": test_group_children,
        "name": "NutriLensTests",
        "sourceTree": "<group>"
    }

    uitests_group_id = gen_id("GROUP_NUTRILENSUITESTS")
    objects[uitests_group_id] = {
        "isa": "PBXGroup",
        "children": uitest_group_children,
        "name": "NutriLensUITests",
        "sourceTree": "<group>"
    }

    objects[main_group_id] = {
        "isa": "PBXGroup",
        "children": [app_group_id, tests_group_id, uitests_group_id, products_group_id],
        "sourceTree": "<group>"
    }

    # Configurations
    # 1. Project level configs
    proj_cfg_debug_id = gen_id("PROJ_CFG_DEBUG")
    proj_cfg_release_id = gen_id("PROJ_CFG_RELEASE")
    proj_cfg_list_id = gen_id("PROJ_CFG_LIST")

    common_project_settings = {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_CXX_LANGUAGE_STANDARD": "gnu++20",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
        "GCC_NO_COMMON_BLOCKS": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "SDKROOT": "iphoneos",
        "SWIFT_VERSION": "5.0"
    }

    debug_project_settings = dict(common_project_settings)
    debug_project_settings.update({
        "DEBUG_INFORMATION_FORMAT": "dwarf",
        "ENABLE_TESTABILITY": "YES",
        "GCC_OPTIMIZATION_LEVEL": "0",
        "ONLY_ACTIVE_ARCH": "YES",
        "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
    })

    release_project_settings = dict(common_project_settings)
    release_project_settings.update({
        "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
        "ENABLE_NS_ASSERTIONS": "NO",
        "SWIFT_COMPILATION_MODE": "wholemodule",
        "SWIFT_OPTIMIZATION_LEVEL": "-O"
    })

    objects[proj_cfg_debug_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": debug_project_settings,
        "name": "Debug"
    }
    objects[proj_cfg_release_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": release_project_settings,
        "name": "Release"
    }
    objects[proj_cfg_list_id] = {
        "isa": "XCConfigurationList",
        "buildConfigurations": [proj_cfg_debug_id, proj_cfg_release_id],
        "defaultConfigurationIsVisible": "0",
        "defaultConfigurationName": "Release"
    }

    # 2. App target configs
    app_cfg_debug_id = gen_id("APP_CFG_DEBUG")
    app_cfg_release_id = gen_id("APP_CFG_RELEASE")
    app_cfg_list_id = gen_id("APP_CFG_LIST")

    app_build_settings = {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "DEVELOPMENT_TEAM": "",
        "ENABLE_PREVIEWS": "YES",
        "GENERATE_INFOPLIST_FILE": "NO",
        "INFOPLIST_FILE": "NutriLens/Resources/Info.plist",
        "INFOPLIST_KEY_CFBundleDisplayName": "NutriLens",
        "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
        "MARKETING_VERSION": "1.0.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.nutrilens.app",
        "PRODUCT_NAME": "NutriLens",
        "SWIFT_EMIT_LOC_STRINGS": "YES"
    }

    objects[app_cfg_debug_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": app_build_settings,
        "name": "Debug"
    }
    objects[app_cfg_release_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": app_build_settings,
        "name": "Release"
    }
    objects[app_cfg_list_id] = {
        "isa": "XCConfigurationList",
        "buildConfigurations": [app_cfg_debug_id, app_cfg_release_id],
        "defaultConfigurationIsVisible": "0",
        "defaultConfigurationName": "Release"
    }

    # 3. Test target configs
    test_cfg_debug_id = gen_id("TEST_CFG_DEBUG")
    test_cfg_release_id = gen_id("TEST_CFG_RELEASE")
    test_cfg_list_id = gen_id("TEST_CFG_LIST")

    test_build_settings = {
        "BUNDLE_LOADER": "$(TEST_HOST)",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "YES",
        "MARKETING_VERSION": "1.0.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.nutrilens.app.tests",
        "PRODUCT_NAME": "NutriLensTests",
        "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/NutriLens.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/NutriLens"
    }

    objects[test_cfg_debug_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": test_build_settings,
        "name": "Debug"
    }
    objects[test_cfg_release_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": test_build_settings,
        "name": "Release"
    }
    objects[test_cfg_list_id] = {
        "isa": "XCConfigurationList",
        "buildConfigurations": [test_cfg_debug_id, test_cfg_release_id],
        "defaultConfigurationIsVisible": "0",
        "defaultConfigurationName": "Release"
    }

    # 4. UI Test target configs
    uitest_cfg_debug_id = gen_id("UITEST_CFG_DEBUG")
    uitest_cfg_release_id = gen_id("UITEST_CFG_RELEASE")
    uitest_cfg_list_id = gen_id("UITEST_CFG_LIST")

    uitest_build_settings = {
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "YES",
        "MARKETING_VERSION": "1.0.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.nutrilens.app.uitests",
        "PRODUCT_NAME": "NutriLensUITests",
        "TEST_TARGET_NAME": "NutriLens"
    }

    objects[uitest_cfg_debug_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": uitest_build_settings,
        "name": "Debug"
    }
    objects[uitest_cfg_release_id] = {
        "isa": "XCBuildConfiguration",
        "buildSettings": uitest_build_settings,
        "name": "Release"
    }
    objects[uitest_cfg_list_id] = {
        "isa": "XCConfigurationList",
        "buildConfigurations": [uitest_cfg_debug_id, uitest_cfg_release_id],
        "defaultConfigurationIsVisible": "0",
        "defaultConfigurationName": "Release"
    }

    # Targets
    objects[app_target_id] = {
        "isa": "PBXNativeTarget",
        "buildConfigurationList": app_cfg_list_id,
        "buildPhases": [app_sources_build_phase_id, app_frameworks_build_phase_id, app_resources_build_phase_id],
        "buildRules": [],
        "dependencies": [],
        "name": "NutriLens",
        "productName": "NutriLens",
        "productReference": app_product_ref_id,
        "productType": "com.apple.product-type.application"
    }

    objects[test_target_id] = {
        "isa": "PBXNativeTarget",
        "buildConfigurationList": test_cfg_list_id,
        "buildPhases": [test_sources_build_phase_id, test_frameworks_build_phase_id, test_resources_build_phase_id],
        "buildRules": [],
        "dependencies": [test_dependency_id],
        "name": "NutriLensTests",
        "productName": "NutriLensTests",
        "productReference": test_product_ref_id,
        "productType": "com.apple.product-type.bundle.unit-test"
    }

    objects[uitest_target_id] = {
        "isa": "PBXNativeTarget",
        "buildConfigurationList": uitest_cfg_list_id,
        "buildPhases": [uitest_sources_build_phase_id, uitest_frameworks_build_phase_id, uitest_resources_build_phase_id],
        "buildRules": [],
        "dependencies": [uitest_dependency_id],
        "name": "NutriLensUITests",
        "productName": "NutriLensUITests",
        "productReference": uitest_product_ref_id,
        "productType": "com.apple.product-type.bundle.ui-testing"
    }

    # Project
    objects[proj_id] = {
        "isa": "PBXProject",
        "attributes": {
            "BuildIndependentTargetsInParallel": "YES",
            "LastSwiftUpdateCheck": "1600",
            "LastUpgradeCheck": "1600",
            "TargetAttributes": {
                app_target_id: {
                    "CreatedOnToolsVersion": "16.0"
                },
                test_target_id: {
                    "CreatedOnToolsVersion": "16.0",
                    "TestTargetID": app_target_id
                },
                uitest_target_id: {
                    "CreatedOnToolsVersion": "16.0",
                    "TestTargetID": app_target_id
                }
            }
        },
        "buildConfigurationList": proj_cfg_list_id,
        "compatibilityVersion": "Xcode 14.0",
        "developmentRegion": "en",
        "hasScannedForEncodings": "0",
        "knownRegions": ["en", "Base"],
        "mainGroup": main_group_id,
        "productRefGroup": products_group_id,
        "projectDirPath": "",
        "projectRoot": "",
        "targets": [app_target_id, test_target_id, uitest_target_id]
    }

    pbx = {
        "archiveVersion": 1,
        "classes": {},
        "objectVersion": "56",
        "objects": objects,
        "rootObject": proj_id
    }

    xcodeproj_dir = os.path.join(root_dir, "NutriLens.xcodeproj")
    os.makedirs(xcodeproj_dir, exist_ok=True)
    pbx_path = os.path.join(xcodeproj_dir, "project.pbxproj")
    with open(pbx_path, "wb") as f:
        plistlib.dump(pbx, f, fmt=plistlib.FMT_XML)

    # Shared scheme
    scheme_dir = os.path.join(xcodeproj_dir, "xcshareddata", "xcschemes")
    os.makedirs(scheme_dir, exist_ok=True)

    scheme_xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_id}"
               BuildableName = "NutriLens.app"
               BlueprintName = "NutriLens"
               ReferencedContainer = "container:NutriLens.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{test_target_id}"
               BuildableName = "NutriLensTests.xctest"
               BlueprintName = "NutriLensTests"
               ReferencedContainer = "container:NutriLens.xcodeproj">
            </BuildableReference>
         </TestableReference>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{uitest_target_id}"
               BuildableName = "NutriLensUITests.xctest"
               BlueprintName = "NutriLensUITests"
               ReferencedContainer = "container:NutriLens.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "NutriLens.app"
            BlueprintName = "NutriLens"
            ReferencedContainer = "container:NutriLens.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "NutriLens.app"
            BlueprintName = "NutriLens"
            ReferencedContainer = "container:NutriLens.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''
    with open(os.path.join(scheme_dir, "NutriLens.xcscheme"), "w", encoding="utf-8") as f:
        f.write(scheme_xml)

    print("Successfully generated NutriLens.xcodeproj and NutriLens.xcscheme")

if __name__ == "__main__":
    main()
