<h1 align="center">
📄<br>Unmap VMFS Datastore
</h1>

## 📚 Unmap VMFS Datastores - from versions 3 to 5

> A long-forgotten function called UNMAP, which uses VAAI to restore the virtual machine disk space to the disk array, first debuted in the upgraded versions of VMware vSphere, notably versions 6.5 and 6.7. This feature is comparable to Windows' TRIM command. The manual execution of a number of intricate and perhaps overwhelming commands was necessary in the past for this wonderful feature (even in version 5). Now that this functionality can be managed from the GUI and disk blocks are automatically returned, everything has gotten much simpler. The dead space reclamation happens not at one but smoothly so there shouldn't happen any issues with the performance. It should be noted that in the case of Snapshot and Storage vMotion the dead space reclamation doesn't perform in automatic mode on the array LUN.

- Link para o artigo completo - [Clique aqui para ler](https://www.diskinternals.com/vmfs-recovery/esxcli-storage-vmfs-unmap/)

<div align="center">
  <br/>
  <br/>
  <br/>
    <div>
      <h1>Open Source</h1>
      <sub>Copyright © 2023 - <a href="https://github.com/julianoabr">julianoabr</sub></a>
    </div>
    <br/>
    📚
</div>


