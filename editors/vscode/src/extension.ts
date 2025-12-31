// SPDX-License-Identifier: MIT OR Apache-2.0
// Betlang VSCode Extension
// Thin wrapper that spawns the bet-lsp language server

import * as vscode from 'vscode';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
    TransportKind
} from 'vscode-languageclient/node';

let client: LanguageClient | undefined;
let outputChannel: vscode.OutputChannel;

export function activate(context: vscode.ExtensionContext) {
    outputChannel = vscode.window.createOutputChannel('Betlang');
    outputChannel.appendLine('Betlang extension activating...');

    // Start the language client
    startLanguageClient(context);

    // Register commands
    context.subscriptions.push(
        vscode.commands.registerCommand('betlang.startRepl', startRepl),
        vscode.commands.registerCommand('betlang.stopRepl', stopRepl),
        vscode.commands.registerCommand('betlang.evalSelection', evalSelection),
        vscode.commands.registerCommand('betlang.restartServer', () => restartServer(context))
    );

    outputChannel.appendLine('Betlang extension activated');
}

function startLanguageClient(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('betlang');
    const lspPath = config.get<string>('lspPath', 'bet-lsp');

    // Server options - spawn the LSP server
    const serverOptions: ServerOptions = {
        run: {
            command: lspPath,
            transport: TransportKind.stdio
        },
        debug: {
            command: lspPath,
            transport: TransportKind.stdio,
            options: {
                env: { ...process.env, RUST_BACKTRACE: '1' }
            }
        }
    };

    // Client options
    const clientOptions: LanguageClientOptions = {
        documentSelector: [
            { scheme: 'file', language: 'betlang' }
        ],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher('**/*.{bet,betlang}')
        },
        outputChannel: outputChannel,
        initializationOptions: {
            enableDiagnostics: config.get<boolean>('enableDiagnostics', true),
            enableCompletion: config.get<boolean>('enableCompletion', true),
            enableHover: config.get<boolean>('enableHover', true)
        }
    };

    // Create and start the client
    client = new LanguageClient(
        'betlang',
        'Betlang Language Server',
        serverOptions,
        clientOptions
    );

    client.start().then(() => {
        outputChannel.appendLine('Language server started');
    }).catch((error) => {
        outputChannel.appendLine(`Failed to start language server: ${error}`);
        vscode.window.showErrorMessage(
            `Failed to start Betlang language server. Make sure 'bet-lsp' is installed and in your PATH.`
        );
    });

    context.subscriptions.push(client);
}

async function restartServer(context: vscode.ExtensionContext) {
    outputChannel.appendLine('Restarting language server...');

    if (client) {
        await client.stop();
    }

    startLanguageClient(context);
}

async function startRepl() {
    if (!client) {
        vscode.window.showErrorMessage('Language server not running');
        return;
    }

    try {
        const result = await client.sendRequest('betlang/repl/start', {});
        outputChannel.appendLine(`REPL started: ${JSON.stringify(result)}`);
        vscode.window.showInformationMessage('Betlang REPL started');
    } catch (error) {
        vscode.window.showErrorMessage(`Failed to start REPL: ${error}`);
    }
}

async function stopRepl() {
    if (!client) {
        return;
    }

    try {
        await client.sendRequest('betlang/repl/stop', {});
        outputChannel.appendLine('REPL stopped');
        vscode.window.showInformationMessage('Betlang REPL stopped');
    } catch (error) {
        vscode.window.showErrorMessage(`Failed to stop REPL: ${error}`);
    }
}

async function evalSelection() {
    const editor = vscode.window.activeTextEditor;
    if (!editor || !client) {
        return;
    }

    const selection = editor.selection;
    const code = selection.isEmpty
        ? editor.document.lineAt(selection.start.line).text
        : editor.document.getText(selection);

    if (!code.trim()) {
        return;
    }

    try {
        const result = await client.sendRequest('betlang/eval', { code });
        outputChannel.appendLine(`> ${code}`);
        outputChannel.appendLine((result as any).result || '<no result>');
        outputChannel.show(true);
    } catch (error) {
        outputChannel.appendLine(`Error: ${error}`);
        outputChannel.show(true);
    }
}

export function deactivate(): Thenable<void> | undefined {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
