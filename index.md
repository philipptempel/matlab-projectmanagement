# Matlab Project Management 'MatProjMan'

This is a simple project management package for MATLAB that will enhance your work to new levels.
Using MatProjMan you can

* Manage projects with dependencies on other projects
* Easily switch between, activate, and deactivate projects
* Easily add, update, or remove projects

## Install

Clone this repository to a location of your liking and then run the installation script from within the root directory

```matlab
>> install()
```

### Dependencies

You will need to have access to the following MATLAB toolboxes

* **Bioinformatics Toolbox**: needed to correctly resolve project dependencies

## Usage

The main concept behind MatProjMan is each project being an object (of type `projman.project`) that supports performing certain functions on it.
A project is defined, at its minimum, through a path that defines the location of the project on your local system.
Additionally, you may have projects that depend on other projects.
Imagine having a general purpose toolbox like [my MATLAB Tooling](https://github.com/iswunistuttgart/matlab-tooling) box that you want loaded whenever you load some other project.
Hierarchically speaking, we assume the following project structure
```
                    tooling
                   /      \
            project a      project b
```
such that `tooling` is dependency of both `project a` and `project b`, or, `project a` and `project b` both use functions from `tooling` and thus require `tooling` on MATLAB's search path.
By defining these dependencies on the object level, you can simply `open` your project `project a` and it will make sure that project `tooling` is also going to be loaded.

### Adding a New Project

If you want to register a new project with the project manager, you must create a new `projman.project` object pointing to the right path
```matlab
p = projman.path('/path/to/project')
% Or you want to set an explicit name
p = projman.path('/path/to/project', 'Some project')
```

To register the project and be able to use it later on, too, we need to register it with the project manager.
This is as simple as concatenating the old projects with the new one and saving the project manager instance.
```matlab
% Get a clean project manager instance
pjm = pm('reset');
% Append the new project p to the existing projects by concatenation
pjm = [pjm, p]
% And now save the project manager instance
save(pjm)
```

By default, the project manager configuration i.e., all `projman.project` objects, will be saved to `userpath/projects_<computername>.mat`.
With your computername being appended to the filename you can have different projects on different computers or the same projects with different locations on different computers.
Care to know the exact filename? See `projman.manager.filename()`.


### Changing Project Properties

To change properties of a project, you need to find it inside the list of projects in the project manager.
You can use fuzzy search on the project names using the `projman.manager.find(name)` method like
```matlab
p = find(pm, 'tooling')
```

If the project named `tooling` cannot be found, an exception will be thrown also listing other projects with similar names (in case you had a typo in your search query).
Then, `p` is a `projman.project` object that you can just change properties of e.g., the path
```matlab
p.Path = '/new/path/to/project';
% Update the project inside the project manager instance pjm
pjm = horzcat(pjm, p);
% And save everything
save(pjm)
```

If you add an existing project to the list of projects it will not result in duplicate entries but will actually make sure that there only is one project for every path.
Per definition, a project is uniquely defined by its path so no two projects can share the same path (however, `project b` may be in a subdirectory of `project a`).


### Opening a Project

Opening a project means making sure every dependency is pushed to the MATLAB search path and lastly our main project is pushed to the MATLAB search path, too.
During opening process, a `projpath.m` is searched which must return a cell array of paths that should be added to MATLAB search path for the project to work correctly.
If the MATLAB search path was successfully updated, the `startup.m` function of the project is run (if it exists), inside of which you can run any startup routines.
Lastly, the current working directory is changed to the project's root folder.

#### Example
```matlab
% Find the projman.project object in the list of all projects
p = find(pm, 'tooling')
% Open the project
open(p);
% Or alternatively
p.open();
```
The short version would be
```matlab
open(find(pm, 'tooling'))
```


### Closing a Project

To close a project i.e., reversing the opening process for the current project only, run the `close` function on the project object.
This will run the `finish.m` function (if it exists) and remove all paths defined in `projpath()` from the MATLAB search path.
However, different to project opening, the dependencies are not automatically removed from the MATLAB search path.

#### Example
```matlab
% Find the projman.project object in the list of all projects
p = find(pm, 'tooling')
% Close the project
close(p);
% Or alternatively
p.close();
```
The short version would be
```matlab
close(find(pm, 'tooling'))
```

### Going to a Project

Sometimes you might want to change directories to a project.
You can use just `cd` on the project object to change the current working directory to the project's root directory.

#### Example
```matlab
% Find the projman.project object in the list of all projects
p = find(pm, 'tooling')
% Go to the project's root dir
cd(p);
% Or alternatively
p.cd();
```
The short version would be
```matlab
cd(find(pm, 'tooling'))
```


### List of Commands

#### Commands on a `projman.project` instance

We assume that `p` and `q` are objects of type `projman.project`.

| Command | Purpose |
| ------- | ------- |
| `addpath(p)` | Add paths of the project and its dependencies to MATLAB search path |
| `open(p)` | Activate a project, its dependencies |
| `cd(p)` | Change current working directory to the project's root |
| `config(p, key)` | Returns the project's configuration value for key `key` |
| `deactivate(p)` | Deactivate a project and change back to the working directory of before activating the project |
| `digraph(p)` | Turns the project into a directed graph object containing the project `p` and all its dependencies |
| `exist(p)` | Check if project exists i.e., if its root directory is an existing directory |
| `finish(p)` | Run the project's `finish.m` function/script (if it exists) |
| `fullfile(p)` | Overwrites MATLAB's `fullfile` method to return paths relative to `p.Path` |
| `is_dependency_of(p, q)` | Check if project `p` is a dependency of `q` |
| `is_dependent_on(p, q)` | Check if project `p` is dependent on `q` i.e., `q` is a dependency of `p` |
| `path(p)` | Return the project's path |
| `pathdef(p)` | Evaluate the project's `pathdef()` function and return the cell array of paths that need to added to MATLAB search path |
| `plot(p)` | Plot the project and its dependencies in a directed graph object |
| `reset(p)` | Short hand command for calling `p.finish()` and `p.startup()` |
| `rmpath(p)` | Remove paths of the project from MATLAB search path |
| `startup(p)` | Evaluate the project's `startup.m` function/script (if it exists) |
| `table(p)` | Convert the project(s) into a MATLAB table with columns 'Name', 'Path', 'Dependencies' |



## Issues, Wishes

Feel free to test the code for bugs, improvements, or things that you would want to see.
For any of these, feel free to head over to the [GH Issues](https://github.com/philipptempel/matlab-projectmanagement/issues) page and submit your issue or feature request.


## Version History
1.0 Initial release of the object-oriented version of MatProjMan.
