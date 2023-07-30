<h1 align="center">
📄<br>Unmap VMFS Datastore
</h1>

## 📚 Unmap VMFS Datastores - from versions 3 to 5

> A long-forgotten function called UNMAP, which uses VAAI to restore the virtual machine disk space to the disk array, first debuted in the upgraded versions of VMware vSphere, notably versions 6.5 and 6.7. This feature is comparable to Windows' TRIM command. The manual execution of a number of intricate and perhaps overwhelming commands was necessary in the past for this wonderful feature (even in version 5). Now that this functionality can be managed from the GUI and disk blocks are automatically returned, everything has gotten much simpler. The dead space reclamation happens not at one but smoothly so there shouldn't happen any issues with the performance. It should be noted that in the case of Snapshot and Storage vMotion the dead space reclamation doesn't perform in automatic mode on the array LUN.

- Link for Complete Article - [Clique aqui para ler](https://www.diskinternals.com/vmfs-recovery/esxcli-storage-vmfs-unmap/)
- How to Encrypt Password and use Aes Key on Powershell - [Clique aqui para ler](https://www.altaro.com/msp-dojo/encrypt-password-powershell/)

## Pre-requisitos

> Powershell versão 5.1 ou superior

> Powercli versão 10 ou superior

## O que este script faz?

1. Conecta no vCenter especificado
2. Guarda numa variável o nome de todos os Hosts
3. Guarda em outra variável o nome de todos os Datastores
4. Valida a versão do VMFS de cada Datastore
5. Roda o Unmap apenas nos Datastores com versão inferior a 6

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


