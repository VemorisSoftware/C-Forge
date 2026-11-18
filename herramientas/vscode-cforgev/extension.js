"use strict";

// Extensión de C-Forge para VS Code: cliente del servidor de lenguaje
// "cforge lsp" (diagnósticos, autocompletado, ir a la definición,
// información al pasar el cursor y formateo) y comandos para ejecutar,
// comprobar y formatear archivos .cfv.
const vscode = require("vscode");
const { LanguageClient, TransportKind } = require("vscode-languageclient/node");

let client;

function cforgePath() {
  return vscode.workspace.getConfiguration("cforge").get("ruta") || "cforge";
}

function startClient(context) {
  if (!vscode.workspace.getConfiguration("cforge").get("lsp.habilitado", true)) return;
  const serverOptions = {
    command: cforgePath(),
    args: ["lsp"],
    transport: TransportKind.stdio
  };
  const clientOptions = {
    documentSelector: [{ scheme: "file", language: "cforge" }, { scheme: "untitled", language: "cforge" }],
    outputChannelName: "C-Forge"
  };
  client = new LanguageClient("cforge", "C-Forge", serverOptions, clientOptions);
  client.start().catch(error => {
    vscode.window.showWarningMessage(
      `C-Forge: no se pudo iniciar "${cforgePath()} lsp" (${error.message}). ` +
      "Instala C-Forge desde https://c-forge.org o ajusta el ajuste cforge.ruta."
    );
  });
  context.subscriptions.push({ dispose: () => client && client.stop() });
}

function runInTerminal(args) {
  const editor = vscode.window.activeTextEditor;
  if (!editor || editor.document.isUntitled) return;
  editor.document.save().then(() => {
    const terminal = vscode.window.createTerminal("C-Forge");
    terminal.show();
    terminal.sendText([cforgePath(), ...args, JSON.stringify(editor.document.uri.fsPath)].join(" "));
  });
}

function activate(context) {
  startClient(context);
  context.subscriptions.push(vscode.commands.registerCommand("cforge.runFile", () => runInTerminal(["run"])));
  context.subscriptions.push(vscode.commands.registerCommand("cforge.checkFile", () => runInTerminal(["check"])));
  context.subscriptions.push(vscode.commands.registerCommand("cforge.formatFile", () =>
    vscode.commands.executeCommand("editor.action.formatDocument")));
  context.subscriptions.push(vscode.commands.registerCommand("cforge.restartServer", async () => {
    if (client) await client.stop();
    startClient(context);
  }));
}

function deactivate() {
  return client ? client.stop() : undefined;
}

module.exports = { activate, deactivate };
