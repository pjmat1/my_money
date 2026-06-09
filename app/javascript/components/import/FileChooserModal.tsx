import React, { ChangeEvent, useState } from 'react'
import { Modal, Button } from 'react-bootstrap'

import { Account } from 'types/models'

type FileChooserModalProps = {
  show: boolean
  account: Account
  onHide: () => void
  onImport: (file: File) => void
}

const FileChooserModal = (props: FileChooserModalProps) => {
  const [file, setFile] = useState<File | null | undefined>(null)
  const [inputKey, setInputKey] = useState<string>('startKey')

  const onImport = () => {
    if (file) {
      props.onImport(file)
    }
  }

  const onChooseFile = (event: ChangeEvent<HTMLInputElement>) => {
    setFile(event.target.files?.item(0))
  }

  const clearFile = () => {
    setInputKey(Math.random().toString(36))
    setFile(null)
  }

  const renderFileName = () => {
    if (file) {
      return (
        <span className="file-name-display">
          {file.name}
          <i className="fa fa-times-circle" onClick={clearFile} />
        </span>
      )
    }
    return undefined
  }

  return (
    <Modal show={props.show} onHide={props.onHide}>
      <Modal.Header>
        <Modal.Title>Import Transactions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <p>
          Please select a file to import transactions into the &apos;
          <strong>{props.account.name}</strong>
          &apos; Account. The file must be in OFX, CSV, or PDF format
        </p>
        <p>Choose File:</p>
        <div className="file-chooser">
          <label htmlFor="fileChooser" className="btn btn-primary">
            <i className="fa fa-folder-open-o" />
          </label>
          <input
            id="fileChooser"
            key={inputKey}
            name="fileChooser"
            type="file"
            style={{ display: 'none' }}
            accept="application/pdf,.pdf,text/csv,.csv,.ofx"
            onChange={onChooseFile}
          />
          {renderFileName()}
        </div>
      </Modal.Body>
      <Modal.Footer>
        <Button className="btn btn-default" onClick={props.onHide}>
          Cancel
        </Button>
        <Button className="btn btn-success" disabled={!file} onClick={onImport}>
          Import
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default FileChooserModal
