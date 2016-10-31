gift = require 'gift'
{View} = require 'space-pen'
{ScrollView, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

git = require '../git'
notifier = require '../notifier'

disposables = new CompositeDisposable

letterToStatusMap =
  A: 'added'
  D: 'deleted'
  M: 'modified'

class StatusListView extends View
  @content: (files) ->
    @div =>
      for path, file of files
        @div =>
          @p "#{letterToStatusMap[file.type]}  #{path}"

class CommitView extends ScrollView
  @content: ({files})->
    @div class: 'git-plus commit-beta', =>
      @div class: ''
      @subview 'commitMessage',  new TextEditorView(placeholderText: 'Enter your commit here...')
      @subview 'status', new StatusListView(files)

  initialize: ({repo}) ->
    super
    atom.commands.add '.commit-beta', 'core:save', () =>
      message = @commitMessage.getModel().getText()
      repo.commit message, (err) ->
        console.log(err) if err

module.exports = (repo, {stageChanges, andPush}={}) ->
  currentPane = atom.workspace.getActivePane()
  repository = gift repo.getWorkingDirectory()

  repository.status (err, status) ->
    atom.workspace.addTopPanel(item: new CommitView(repo: repository, files: status.files))
