#!/bin/bash

# e.g 0.1.3
TAG_NAME=$FLOW_RELEASE_NAME
ARCHIVE_URL="https://github.com/estuary/flow/archive/refs/tags/v{$TAG_NAME}.tar.gz"

DOWNLOADS_BASE="https://github.com/estuary/flow/releases/download"
MACOS_BINARY="{$DOWNLOADS_BASE}/v{$TAG_NAME}/flowctl-multiarch-macos"
LINUX_X86_BINARY="{$DOWNLOADS_BASE}/v{$TAG_NAME}/flowctl-x86_64-linux"

ARCHIVE_SHA=$(curl -sL "$ARCHIVE_URL" | shasum -a 256)
MACOS_SHA=$(curl -sL "$MACOS_BINARY" | shasum -a 256)
LINUX_X86_SHA=$(curl -sL "$LINUX_X86_BINARY" | shasum -a 256)

cat << EOF
class Flowctl < Formula
  desc "Command line interface for Flow"
  homepage "https://github.com/estuary/flow"
  url "https://github.com/estuary/flow/archive/refs/tags/v$TAG_NAME.tar.gz"
  sha256 "$ARCHIVE_SHA"
  license "Business Source License 1.1"
  version "$TAG_NAME"

  on_macos do
    resource "flowctl-binary" do
      url "$MACOS_BINARY"
      sha256 "$MACOS_SHA"
    end
  end

  on_linux do
    on_arm do
      raise "flowctl can only be installed on x86_64 linux systems, please reach out to support@estuary.dev if you need flowctl on arm"
    end
    resource "flowctl-binary" do
      url "$LINUX_X86_BINARY"
      sha256 "$LINUX_X86_SHA"
    end
  end

  def install
    binary_name = "flowctl-multiarch-macos"
    if OS.linux?
      binary_name = "flowctl-x86_64-linux"
    end

    resource("flowctl-binary").stage do
      bin.install binary_name => "flowctl"
    end

  end

  test do
    system "flowctl", "--version"
  end
end
EOF