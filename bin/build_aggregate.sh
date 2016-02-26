######################
# Options
######################

FRAMEWORK_NAME="${PROJECT_NAME}"
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"
UNIVERSAL_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneuniversal/${FRAMEWORK_NAME}.framework"

######################
# Build Frameworks
######################

xcodebuild -project ${PROJECT_NAME}.xcodeproj -scheme ${PROJECT_NAME} -sdk macosx -configuration ${CONFIGURATION} build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}

xcodebuild -project ${PROJECT_NAME}.xcodeproj -scheme ${PROJECT_NAME} -sdk iphoneos -configuration ${CONFIGURATION} build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos

xcodebuild -project ${PROJECT_NAME}.xcodeproj -scheme ${PROJECT_NAME} -sdk iphonesimulator -destination "name=iPhone 6" -configuration ${CONFIGURATION} build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator

######################
# Create directory for universal
######################

if [ -d ${UNIVERSAL_LIBRARY_PATH} ]; then
    rm -rf "${UNIVERSAL_LIBRARY_PATH}/*";
fi
mkdir -p "${UNIVERSAL_LIBRARY_PATH}"

######################
# Copy files Framework
######################

cp -r "${DEVICE_LIBRARY_PATH}/." "${UNIVERSAL_LIBRARY_PATH}"

#########################
# Make a universal binary
#########################

lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${UNIVERSAL_LIBRARY_PATH}/${FRAMEWORK_NAME}" | echo

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
    cp -f ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${UNIVERSAL_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi
                                                                      
if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
    cp -f ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${UNIVERSAL_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi
