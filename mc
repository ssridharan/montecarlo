import sys
import random
class montecarlo(object):
    def __init__(self, inputfile = None) :
        self.parent = {}
        self.linkmatrix = {}
        self.value = { }
        self.topoNumber = { }
        self.topoOrder = [ ]
        self.topoNumber = { }
        self.frequencies = { }
        self.frequency = 0
        self.evidence = { }
        
        if inputfile != None:
            self.readfile(inputfile)


    def readMatrix(self, infile):
        header = infile.readline()
        childParentList  = header[header.find("(") + 1:header.find(")")].split("|")
        if len(childParentList) == 1:
            child = childParentList[0]
            parents = []
        else:
            [child,parent] = childParentList
            parents = parent.split(",")
        self.parent[child] = parents
        if parents == []:
            self.linkmatrix[child] = [float(x) for x in infile.readline().split()]
        else:
            self.linkmatrix[child] = []
            for i in range(2**len(parents)):
                nl = infile.readline()
                self.linkmatrix[child].append([float(x) for x in nl.split()])

### Topological sort on the graph defined by the parent pointers
              
    def topoSort(self):
        outDegree = {}
        stack = []
        for x in self.parent:
            outDegree[x] = 0
        for x in self.parent:
            par = self.parent[x]
            for x in par:
                outDegree[x] = outDegree[x] + 1
        zeroOutdegree = [x for x in self.parent if outDegree[x] == 0]
        topoNum = len(self.parent) - 1
        self.topoOrder = [-1] * len(self.parent)
        while (zeroOutdegree != []):
            next = zeroOutdegree.pop()
            self.topoNumber[next] = topoNum
            self.topoOrder[topoNum] = next
            topoNum= topoNum - 1
            par = self.parent[next]
            for x in par:
                outDegree[x] = outDegree[x] - 1
                if outDegree[x] == 0:
                    zeroOutdegree.append(x)


    def readfile(self, filename):
        infile = file(filename)
        numvars = int(infile.readline())
        for i in range(numvars):
            var = infile.readline().split()
        for i in range(numvars):
            self.readMatrix(infile)
        infile.readline()
        evidenceLine = infile.readline()
        while evidenceLine[0] != '-':
            [var, val] = evidenceLine.split()
            self.evidence[var] = int(val)
            evidenceLine = infile.readline()
        self.topoSort()

        


    def doIterations(self, numIterations):
        for variable in self.topoOrder:
            self.frequencies[variable]=0
        expected_value=self.evidence.values()[0]
        for ii in range(numIterations):
            value={}
            for variable in self.topoOrder:
                if not self.parent[variable]:
                    value[variable] = 0 if random.uniform(0,1) > self.linkmatrix[variable][0] else 1
                else:
                    bin=[value[parent] for parent in self.parent[variable]]
                    index=''
                    for iii in range(len(bin)):
                        index=index+str(bin[iii])
                    ind=int(str(index),2)
                    value[variable] = 0 if random.uniform(0,1) > self.linkmatrix[variable][ind][0] else 1
            if value[self.topoOrder[-1]] == expected_value:
                self.frequency+=1
                for variable in value:
                    if value[variable] == 1:
                        self.frequencies[variable]+=1




    def printResults(self):
        print "\n", "Valid Trials : " , self.frequency
        for variable in self.topoOrder:
            print "\n", " P ( ", variable, " ) ", float(self.frequencies[variable])/float(self.frequency)
    
if __name__ == '__main__':
    network = montecarlo(sys.argv[-1])
    network.doIterations(int(sys.argv[-2]))
    network.printResults()
