local IS_WIN = package.config:sub(1,1) == '\\'

if IS_WIN then
    assert(os.execute("rmdir /S /Q build")==0, "Command failed")
else
    assert(os.execute("rm -rf build")==0, "Command failed")
end