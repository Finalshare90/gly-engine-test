local luaunit = require ('luaunit')
local pipeline = require ('src/lib/util/pipeline')


function test_pipe()
    local test_obj = {
        run_called = false,
        run = function(self)
            self.run_called = true
        end
    }
    local task = pipeline.pipe(test_obj)
    task()
    luaunit.assertTrue(test_obj.run_called)
end

function test_stop_pipe()
    local test_obj = {
        pipeline = true,
        pipeline2 = false
    }
    pipeline.stop(test_obj)
    luaunit.assertTrue(test_obj.pipeline2)
    luaunit.assertNil(test_obj.pipeline)
end

function test_resume_pipe()
    local test_obj = {
        pipeline = false,
        pipeline2 = true,
        run = function(self)
            self.pipeline = true
        end
    }
    pipeline.resume(test_obj)
    luaunit.assertTrue(test_obj.pipeline)
end

function test_reset_pipe()
    local test_obj = {
        pipeline_current = 1,
        pipeline = 1,
        pipeline2 = 1,
    }
    pipeline.reset(test_obj)
    luaunit.assertNil(test_obj.pipeline_current)
    luaunit.assertNil(test_obj.pipeline2)
    luaunit.assertEquals(test_obj.pipeline, 1)  
end

function test_run_pipe()
    local test_obj = {
        pipeline_current = nil,
        pipeline = {
            function() end,
            function() end,
            function() end
        }
    }
    pipeline.run(test_obj)
    luaunit.assertEquals(test_obj.pipeline_current, 4)
end


function test_clear_pipe()
    
    
    local test_obj = {
        pipeline_current = 1,
        pipeline2 = 1,
        pipeline = 1,
    }
    pipeline.clear(test_obj)
    luaunit.assertNil(test_obj.pipeline_current)
    luaunit.assertNil(test_obj.pipeline)
    luaunit.assertNil(test_obj.pipeline2)
    
end

os.exit(luaunit.LuaUnit.run())